//
//  Animator.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit
import Combine


class Animator {
	struct State {
		let transform: CGAffineTransform
		let alpha: CGFloat
	}

	typealias StateProvider = (_ progress: Float, _ view: UIView) -> State
	
	// The incoming progress value.
	let progress: AnyPublisher<Float, Never>
	
	// The view in question we animate.
	let view: UIView
	
	// The progress keyframes that define transition segments.
	let keyframes: [Float]

	// Callback to derive the visual state for a keyframe on demand.
	let stateProvider: StateProvider

	// The currently active segment.
	// A segment is the transition between two neighbouring keyframes.
	private var activeSegmentIndex: Int?
	
	// The currently active UIKit animator.
	// Multiple animators on one view can produce strange results,
	// so we keep only one alive.
	private var activeAnimator: UIViewPropertyAnimator?
	
	private var cancellable: AnyCancellable?
	
	init?(
		progress: AnyPublisher<Float, Never>,
		view: UIView,
		keyframes: [Float],
		stateProvider: @escaping StateProvider
	) {
		self.progress = progress
		self.view = view
		self.keyframes = keyframes.sorted()
		self.stateProvider = stateProvider
		self.activeSegmentIndex = nil
		self.activeAnimator = nil
		
		guard isValid else { return nil }
		
		self.cancellable = progress
			.dropFirst()	// we do not want the current value, only those on real changes
			.sink { [weak self] progress in
				self?.applyProgress(progress)
			}
	}
	
	deinit {
		activeAnimator?.stopAnimation(true)
	}

	private var isValid: Bool {
		guard keyframes.count >= 2 else { return false }
		for index in 1..<keyframes.count {
			guard keyframes[index - 1] < keyframes[index] else { return false }
		}
		return true
	}

	private func applyState(_ state: State) {
		view.transform = state.transform
		view.alpha = state.alpha
	}
	
	private func applyProgress(_ progress: Float) {
		guard let segment = segment(for: progress) else { return }
		animator(for: segment.index)
		activeAnimator?.fractionComplete = segment.fraction
	}
	
	private func segment(for progress: Float) -> (index: Int, fraction: CGFloat)? {
		let lastSegmentIndex = keyframes.count - 2
		guard lastSegmentIndex >= 0 else { return nil }

		// Assuming sorted keyframes, use the start of the first segment or...
		if progress <= keyframes[0] {
			return (index: 0, fraction: 0)
		}
		// the end of the last segment for out-of-bounds progress values
		if progress >= keyframes[keyframes.count - 1] {
			return (index: lastSegmentIndex, fraction: 1)
		}
		
		for i in 0...lastSegmentIndex {
			let start = keyframes[i]
			let end = keyframes[i + 1]
			guard progress >= start, progress <= end else { continue }
			
			let span = end - start
			let fraction = CGFloat((progress - start) / span)
			return (index: i, fraction: fraction)
		}
		
		return nil
	}
	
	private func animator(for segmentIndex: Int) {
		guard activeSegmentIndex != segmentIndex || activeAnimator == nil else { return }
		
		activeAnimator?.stopAnimation(true)
		
		let startProgress = keyframes[segmentIndex]
		let endProgress = keyframes[segmentIndex + 1]
		let startState = stateProvider(startProgress, view)
		let endState = stateProvider(endProgress, view)
		applyState(startState)
		
		let duration = TimeInterval(endProgress - startProgress)
		let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak view] in
			view?.transform = endState.transform
			view?.alpha = endState.alpha
		}
		animator.pausesOnCompletion = true
		animator.startAnimation()
		animator.pauseAnimation()
		animator.fractionComplete = 0
		
		activeSegmentIndex = segmentIndex
		activeAnimator = animator
	}
}
