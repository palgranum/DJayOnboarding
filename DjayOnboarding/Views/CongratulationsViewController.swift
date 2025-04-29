//
//  CongratulationsViewController.swift
//  DjayOnboarding
//
//  Created by Pal Granum on 27/04/2025.
//

import UIKit

public protocol CongratulationsViewModelType {
    func didStartPanning()
    func didUpdatePanPosition(_ normalizedPosition: CGPoint)
    func didEndPanning()
    func leftScope(_ nFrames: Int) -> UnsafePointer<Float>
    func rightScope(_ nFrames: Int) -> UnsafePointer<Float>
    var messages: [String] { get }
    func viewWillAppear()
    func viewWillDisappear()
}

/// A view controller that displays some messages to the user.
/// There is an emitter layer with a background animation of musical notes.
/// There is an audio scope effect that shows the current audio signal.
/// User may use pan gesture to change the audio signal.
final public class CongratulationsViewController: UIViewController {
    private let viewModel: CongratulationsViewModelType
    private let emitter = CAEmitterLayer()
    private var displayLink: CADisplayLink?
    private let scopeLayer = CAShapeLayer()
    private let panGesture = UIPanGestureRecognizer()
    private var leftScopePosition: (start: CGPoint, end: CGPoint) = (.zero, .zero)
    private var rightScopePosition: (start: CGPoint, end: CGPoint) = (.zero, .zero)
    private let textLabel = UILabel()
    private var textIndex = 0
    private let labelSize = CGSize(width: OnboardingController.buttonWidth, height: 300)

    init(_ viewModel: CongratulationsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        textLabel.textAlignment = .center
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        textLabel.numberOfLines = 0
        textLabel.alpha = 0
        view.addSubview(textLabel)

        view.layer.addSublayer(scopeLayer)
        scopeLayer.strokeColor = UIColor.buttonBlue.cgColor
        scopeLayer.lineWidth = 2
        scopeLayer.fillColor = UIColor.clear.cgColor

        view.addGestureRecognizer(panGesture)
        panGesture.addTarget(self, action: #selector(didPan))

        let cell1 = CAEmitterCell()
        let cell2 = CAEmitterCell()
        cell1.contents = UIImage(named: "whiteNote")!.cgImage
        cell2.contents = UIImage(named: "whiteNote2")!.cgImage
        cell1.birthRate = 22
        cell1.lifetime = 150
        cell1.velocity = 40
        cell1.velocityRange = 20
        cell1.yAcceleration = 10
        cell1.scale = 0.5
        cell1.scaleRange = 0.45
        cell1.spin = 0.5
        cell1.spinRange = 1.0
        cell1.alphaSpeed = -0.05
        cell2.birthRate = 22
        cell2.lifetime = 150
        cell2.velocity = 40
        cell2.velocityRange = 20
        cell2.yAcceleration = 10
        cell2.scale = 0.5
        cell2.scaleRange = 0.45
        cell2.spin = 0.5
        cell2.spinRange = 1.0
        cell2.alphaSpeed = -0.05
        emitter.emitterCells = [cell1, cell2]
        emitter.emitterShape = .line
        view.layer.addSublayer(emitter)

        showNextMessage()
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let width = max(view.bounds.width, view.bounds.height)
        emitter.emitterPosition = CGPoint(x: width * 0.5, y: -50)
        emitter.emitterSize = CGSize(width: width, height: 1)
        let link = CADisplayLink(target: self, selector: #selector(stepDisplayLink))
        link.add(to: .main, forMode: .common)
        self.displayLink = link
        viewModel.viewWillAppear()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        displayLink = nil
        viewModel.viewWillDisappear()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [textLabel] _ in
            textLabel.center = self.view.center
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scopeLayer.frame = view.bounds
        resetScopePoints()
    }

    private func showNextMessage() {
        // Find the next message to show:
        if textIndex >= viewModel.messages.count { textIndex = 0 }
        textLabel.text = viewModel.messages[textIndex]
        textIndex += 1
        // Pick a random start position for animation, top, bottom, left or right:
        let center = switch Int.random(in: 0...3) {
        case 0: CGPoint(x: (view.bounds.width - labelSize.width) * 0.5, y: -labelSize.height)
        case 1: CGPoint(x: (view.bounds.width - labelSize.width) * 0.5, y: view.bounds.height)
        case 2: CGPoint(x: -labelSize.width, y: view.bounds.height * 0.5 - 0.5 * labelSize.height)
        default: CGPoint(x: view.bounds.width, y: view.bounds.height * 0.5 - 0.5 * labelSize.height)
        }
        UIView.performWithoutAnimation {
            textLabel.frame = CGRect(origin: center, size: labelSize)
            textLabel.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateLabelToCenter()
        }
    }

    /// Animate the label to the center of the screen, then fade it out and show the next message.
    private func animateLabelToCenter() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.textLabel.center = self.view.center
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 3, options: [.curveEaseInOut], animations: {
                self.textLabel.alpha = 0
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.showNextMessage()
                }
            })
        })
    }

    @objc private func didPan() {
        let location = panGesture.location(in: view)

        switch panGesture.state {
        case .possible: break

        case .began:
            viewModel.didStartPanning()

        case .changed:
            guard view.bounds.width > 0, view.bounds.height > 0 else { return }
            let normalized = CGPoint(x: location.x / view.bounds.width,
                                     y: location.y / view.bounds.height)
            viewModel.didUpdatePanPosition(normalized)

        case .cancelled, .ended, .failed:
            resetScopePoints()
            viewModel.didEndPanning()

        @unknown default: fatalError("Unknown gesture state")
        }
    }

    @objc private func stepDisplayLink() {
        let path = CGMutablePath()
        guard view.bounds.width > 0 else { return }
        let nPoints = min(Int(UIScreen.main.scale * view.bounds.width), 4096)
        drawScope(in: path, using: viewModel.leftScope(nPoints), nValues: nPoints, from: leftScopePosition.start, to: leftScopePosition.end)
        drawScope(in: path, using: viewModel.rightScope(nPoints), nValues: nPoints, from: rightScopePosition.start, to: rightScopePosition.end)
        scopeLayer.path = path
    }

    /// Draws an audio scope from startPoint to endPoint into path based on float buffer values in values vector.
    private func drawScope(in path: CGMutablePath,
                          using values: UnsafePointer<Float>,
                          nValues: Int,
                          from startPoint: CGPoint,
                          to endPoint: CGPoint) {
        let gain: Float = 250
        let distance = startPoint.distance(to: endPoint)
        var x: CGFloat = 0
        guard distance > 0 else { return }
        let scopePath = CGMutablePath()
        let indexIncrement = CGFloat(nValues + 1) / distance
        scopePath.move(to: CGPoint(x: x, y: 0))
        let oneOverScale: CGFloat = 1.0 / UIScreen.main.scale
        while x <= distance {
            let index = Int(indexIncrement * x)
            let value = CGFloat(values.advanced(by: index).pointee * gain)
            scopePath.addLine(to: CGPoint(x: x, y: value))
            x += oneOverScale
        }
        let rotationAngle = startPoint.angle(to: endPoint)
        let transform = CGAffineTransform(translationX: startPoint.x, y: startPoint.y - 0.0).rotated(by: rotationAngle)
        path.addPath(scopePath, transform: transform)
    }

    private func resetScopePoints() {
        if view.bounds.height > view.bounds.width {
            leftScopePosition = (start: CGPoint(x: 0, y: 0.25 * view.bounds.height),
                                 end: CGPoint(x: view.bounds.width, y: 0.25 * view.bounds.height))
            rightScopePosition = (start: CGPoint(x: 0, y: 0.75 * view.bounds.height),
                                  end: CGPoint(x: view.bounds.width, y: 0.75 * view.bounds.height))
        } else {
            leftScopePosition = (start: CGPoint(x: view.bounds.width * 0.25, y: 0),
                                 end: CGPoint(x: view.bounds.width * 0.25, y: view.bounds.height))
            rightScopePosition = (start: CGPoint(x: view.bounds.width * 0.75, y: 0),
                                  end: CGPoint(x: view.bounds.width * 0.75, y: view.bounds.height))
        }
    }
}

//#if DEBUG
//@available(iOS 17.0, *)
//#Preview {
//    ReadyController(ReadyViewModel())
//}
//#endif
