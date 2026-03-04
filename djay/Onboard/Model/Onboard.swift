//
//  Onboard.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import Foundation
import Combine


// The model holding the state/progress of the onboarding flow.
// It is meant as the source of truth for the onboarding flow and
// its publishers allow all participants to react to it easily.
class Onboard {
	
	/// Total number of pages.
	var pageCount = 0

	/// Index for the page for which a skill is needed.
	var skillBarrierIndex = 0

	/// Subject for the current progress within the onboarding flow.
	private let progressSubject = CurrentValueSubject<Float, Never>(0)

	/// Subject to hold the current skill, nil if undecided.
	private let skillSubject = CurrentValueSubject<OnboardSkill?, Never>(nil)

	/// Handle for animating progress changes.
	private var progressAnimationCancellable: AnyCancellable?
		
	deinit {
		stopProgressAnimation()
	}
}

// MARK: public progress API

extension Onboard {
	
	/// Float representation of the current progress.
	/// Its non-fractional values equal the raw values of the `OnboardStep` enum.
	/// If you want to animate these changes, use `setProgress(_:, animated:)` directly.
	var progress: Float {
		get { progressSubject.value }
		set {
			stopProgressAnimation()
			_ = applyProgressIfAllowed(newValue)
		}
	}

	/// Method to animate changes for `progress`.
	/// If you want discrete changes, use `progress` directly.
	func setProgress(_ value: Float, animated: Bool) {
		guard animated else {
			progress = value
			return
		}

		guard canApplyProgress(value) else { return }
		
		startProgressAnimation(to: value)
	}

	/// Publisher for listening to progress changes.
	var progressPublisher: AnyPublisher<Float, Never> {
		progressSubject
			.removeDuplicates()
			.eraseToAnyPublisher()
	}

	/// The current `OnboardStep`, read only.
	var step: OnboardStep {
		let value = max(0, min (Int(progress.rounded()), self.pageCount - 1))
		return OnboardStep(rawValue: value) ?? .welcome
	}

	/// Publisher for listening to step changes.
	var stepPublisher: AnyPublisher<OnboardStep, Never> {
		progressPublisher
			.map { [weak self] progress in
				guard let self else { return .welcome }
				let value = max(0, min (Int(progress.rounded()), self.pageCount - 1))
				return OnboardStep(rawValue: value) ?? .welcome
			}
			.removeDuplicates()
			.eraseToAnyPublisher()
	}
}

// MARK: public skill API

extension Onboard {
	/// Optional skill level; `nil` if undecided.
	var skill: OnboardSkill? {
		get { skillSubject.value }
		set { skillSubject.send(newValue) }
	}

	/// Publisher for `OnboardSkill`.
	var skillPublisher: AnyPublisher<OnboardSkill?, Never> {
		skillSubject
			.removeDuplicates()
			.eraseToAnyPublisher()
	}
	
	var isSkillBarrierActive: Bool {
		skill == nil
	}
}

// MARK: private progress helper

extension Onboard {
	private func canApplyProgress(_ value: Float) -> Bool {
		!isSkillBarrierActive || value <= Float(skillBarrierIndex)
	}

	@discardableResult
	private func applyProgressIfAllowed(_ value: Float) -> Bool {
		guard canApplyProgress(value) else { return false }
		progressSubject.send(value)
		return true
	}
}

// MARK: Animate progress changes

// If we want to animate the progress changes by code, Combine has no way to express
// that easily. A `Timer.publish` for 1/60 of a frame should suffice to animate this smoothly,
// but a CADisplayLink could work here as well.
extension Onboard {
	private static let progressAnimationDuration: TimeInterval = 0.2
	private static let progressAnimationFrameInterval: TimeInterval = 1.0 / 60.0

	private func startProgressAnimation(to end: Float) {
		stopProgressAnimation()
		let start = progressSubject.value
		
		let startTime = Date.timeIntervalSinceReferenceDate
		progressAnimationCancellable = Timer
			.publish(
				every: Self.progressAnimationFrameInterval,
				on: .main,
				in: .common)
			.autoconnect()
			.prepend(Date())
			.sink { [weak self] _ in
				guard let self else { return }
				
				let elapsed = Date.timeIntervalSinceReferenceDate - startTime
				let rawTime = min(max(elapsed / Self.progressAnimationDuration, 0), 1)
				let easedTime = rawTime.easeInOut()
				let interpolatedProgress = start + Float(easedTime) * (end - start)
				guard self.applyProgressIfAllowed(interpolatedProgress) else {
					self.stopProgressAnimation()
					return
				}
				
				guard rawTime >= 1 else { return }
				_ = self.applyProgressIfAllowed(end)
				self.stopProgressAnimation()
			}
	}
	
	private func stopProgressAnimation() {
		progressAnimationCancellable?.cancel()
		progressAnimationCancellable = nil
	}
}

fileprivate extension TimeInterval {
	func easeInOut() -> TimeInterval {
		if self < 0.5 {
			return 2 * self * self
		}
		return 1 - pow(-2 * self + 2, 2) / 2
	}
}
