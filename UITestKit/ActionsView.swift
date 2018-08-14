//
//  ActionsView.swift
//  UITestKit
//
//  Created by Quyen Xuan on 8/14/18.
//  Copyright © 2018 Innovatube. All rights reserved.
//

import UIKit

public enum ViewType {
    case overlay
    case split
}

public protocol ActionsViewDelegate: NSObjectProtocol {
    func actionsView(_ actionsView: ActionsView, viewTypeDidChanged type: ViewType)

    func actionsView(_ actionsView: ActionsView, alphaValueChanged newValue: Float)

    func actionsView(_ actionsView: ActionsView, didTapChooseImage sender: Any)
}

open class ActionsView: UIView {
    private lazy var buttonImageName: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose an image", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4

        return button
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "Overlay", at: 0, animated: true)
        control.insertSegment(withTitle: "Split", at: 1, animated: true)

        control.translatesAutoresizingMaskIntoConstraints = false
        control.setContentHuggingPriority(UILayoutPriority(255), for: .vertical)

        return control
    }()

    private lazy var alphaSlider: UISlider = {
        let slider = UISlider()
        slider.isContinuous = true
        slider.maximumTrackTintColor = .white
        slider.minimumTrackTintColor = .blue
        slider.translatesAutoresizingMaskIntoConstraints = false

        return slider
    }()

    private lazy var alphaLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority(255), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(755), for: .horizontal)

        return label
    }()

    private lazy var alphaStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [alphaSlider])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    open var delegate: ActionsViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        addActions()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setupUI() {
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        layer.masksToBounds = true
        layer.cornerRadius = 4

        let stackView = UIStackView(arrangedSubviews: [buttonImageName, segmentedControl, alphaStackView])
        stackView.axis = .vertical
        stackView.spacing = 16

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            alphaLabel.widthAnchor.constraint(equalToConstant: 24)
        ])

        // Set selected first index by default
        segmentedControl.selectedSegmentIndex = 0
        alphaSlider.setValue(1.0, animated: false)
    }

    private func addActions() {
        buttonImageName.addTarget(self, action: #selector(handlerImageNameButtonDidPressed(_:)), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(handlerSegmentControlValueChanged(_:)), for: .valueChanged)
        alphaSlider.addTarget(self, action: #selector(handlerAlphaSliderValueChanged(_:)), for: .valueChanged)
    }

    @objc
    private func handlerImageNameButtonDidPressed(_ sender: Any) {
        delegate?.actionsView(self, didTapChooseImage: sender)
    }

    @objc
    private func handlerSegmentControlValueChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            alphaStackView.subviews.forEach { $0.isHidden = false }
            alphaStackView.isHidden = false

            delegate?.actionsView(self, viewTypeDidChanged: .overlay)
        case 1:
            alphaStackView.subviews.forEach { $0.isHidden = true }
            alphaStackView.isHidden = true

            // Reset alpha slider value to 1.0
            alphaSlider.setValue(1.0, animated: false)

            delegate?.actionsView(self, alphaValueChanged: 1.0)
            delegate?.actionsView(self, viewTypeDidChanged: .split)
        default:
            break
        }
    }

    @objc
    private func handlerAlphaSliderValueChanged(_ sender: Any) {
        var alpha = alphaSlider.value
        if alpha < 0.15 {
            alpha = 0.15
            alphaSlider.value = 0.15
        }
        alphaLabel.text = "\(alpha)"
        delegate?.actionsView(self, alphaValueChanged: alpha)
    }
}
