//
//  TomView.swift
//  Tom
//
//  Created by Yusuf Demirci on 30.03.21.
//

final public class TomView: UIView {

    // MARK: Properties

    private let stackView: UIStackView = {
        let view: UIStackView = .init()
        view.distribution = .fillEqually
        return view
    }()

    private var lineViews: [LineView] = []
    private var isAnimationEnabled: Bool = false

    private let configuration: Configuration

    public init(configuration: Configuration, frame: CGRect = .init()) {
        self.configuration = configuration

        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Publics

public extension TomView {

    /// Starts animation for each lines
    func start() {
        isAnimationEnabled = true

        lineViews.forEach { [weak self] lineView in
            self?.animate(lineView: lineView)
        }
    }

    /// Stops animation for each lines
    func stop() {
        isAnimationEnabled = false

        lineViews.forEach { [weak self] lineView in
            lineView.heightConstraint?.constant = self?.configuration.minLineHeight ?? 0

            UIView.animate(withDuration: configuration.animationSpeed) {
                self?.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Privates

private extension TomView {

    func setup() {
        stackView.spacing = configuration.lineSpacing
        stackView.axis = configuration.axis

        self.addSubview(stackView)
        stackView.pinView(to: self)

        addLinesToStackView()
    }

    func animate(lineView: UIView) {
        guard let maxHeight = lineView.superview?.frame.height else { return }

        let newHeight = CGFloat.random(in: configuration.minLineHeight...maxHeight)
        lineView.heightConstraint?.constant = newHeight

        UIView.animate(withDuration: configuration.animationSpeed) { [weak self] in
            self?.layoutIfNeeded()
        } completion: { [weak self] _ in
            if self?.isAnimationEnabled ?? false {
                self?.animate(lineView: lineView)
            }
        }
    }
    
    func addLinesToStackView() {
        for _ in 0 ..< configuration.lineCount {
            let lineView: LineView = .init(
                configuration: .init(
                    color: configuration.lineColor,
                    cornerRadius: .rounded
                )
            )

            let containerView: UIView = .init()
            containerView.addSubview(lineView)

            setLineConstraints(lineView: lineView, containerView: containerView)

            stackView.addArrangedSubview(containerView)
            lineViews.append(lineView)
        }
    }

    func setLineConstraints(lineView: UIView, containerView: UIView) {
        lineView.translatesAutoresizingMaskIntoConstraints = false

        lineView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        lineView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: configuration.minLineHeight).isActive = true
        lineView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        lineView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
    }
}
