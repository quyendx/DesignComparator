//
//  ActionsViewController.swift
//  UITestKit
//
//  Created by Quyen Xuan on 8/14/18.
//  Copyright © 2018 Innovatube. All rights reserved.
//

import UIKit

class ActionsViewController: UIViewController {

    private lazy var imagePicker: UIImagePickerController = {
        [unowned self] in
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self

        return picker
    }()

    private lazy var controlActionsView: ActionsView = {
        [unowned self] in
        let actionsView = ActionsView(frame: .zero)
        actionsView.delegate = self
        actionsView.translatesAutoresizingMaskIntoConstraints = false

        return actionsView
    }()

    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    private lazy var maskLayer: CAShapeLayer = {
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd

        return maskLayer
    }()

    private lazy var leadingConstraint: NSLayoutConstraint = backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlerPanGesture(_:)))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // TODO: Allow this view move around the screen
    private func setupUI() {
        // Add image background
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            leadingConstraint,
            view.trailingAnchor.constraint(greaterThanOrEqualTo: backgroundImage.trailingAnchor),
            view.bottomAnchor.constraint(greaterThanOrEqualTo: backgroundImage.bottomAnchor)
        ])

        view.addSubview(controlActionsView)
        NSLayoutConstraint.activate([
            controlActionsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            controlActionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlActionsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            view.trailingAnchor.constraint(greaterThanOrEqualTo: controlActionsView.trailingAnchor, constant: 16),
            view.bottomAnchor.constraint(greaterThanOrEqualTo: controlActionsView.bottomAnchor, constant: 16)
        ])

        // Add overlay layer
        view.layer.mask = maskLayer
        view.clipsToBounds = true
    }

    @objc
    private func handlerPanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)

        switch recognizer.state {
        case .began:
            var newFrame = maskLayer.frame
            newFrame.origin.x += translation.x
            newFrame.size.width = view.frame.width - newFrame.origin.x

            maskLayer.frame = newFrame

        case .changed:
            guard let recognizerView = recognizer.view else { return }

            recognizer.setTranslation(CGPoint.zero, in: recognizerView)

            var newFrame = maskLayer.frame
            newFrame.origin.x += translation.x
            if newFrame.origin.x < 0 {
                newFrame.origin.x = 0
            }
            newFrame.size.width = view.frame.width - newFrame.origin.x

            maskLayer.frame = newFrame

        case .failed:
            maskLayer.frame = view.frame
        default:
            break
        }
    }

}

extension ActionsViewController: ActionsViewDelegate {
    func actionsView(_ actionsView: ActionsView, viewTypeDidChanged type: ViewType) {
        switch type {
        case .overlay:
            view.removeGestureRecognizer(panGesture)
            
        case .split:
            view.addGestureRecognizer(panGesture)
        }
    }

    func actionsView(_ actionsView: ActionsView, alphaValueChanged newValue: Float) {
        backgroundImage.alpha = CGFloat(newValue)
    }

    func actionsView(_ actionsView: ActionsView, didTapChooseImage sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

}

extension ActionsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }

        backgroundImage.image = image
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
