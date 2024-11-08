//
//  UIKit Carousel.swift
//  Studies
//
//  Created by Adam Kuzma on 11/7/24.
//

import UIKit
import SwiftUI


// MARK: - Custom Layout
class CarouselLayout: UICollectionViewLayout {
    private let itemSize = CGSize(width: 280, height: 250)
    var spacing: CGFloat = -100  // Make spacing variable
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let width = CGFloat(collectionView.numberOfItems(inSection: 0)) * (itemSize.width + spacing) - spacing
        return CGSize(width: width, height: itemSize.height)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let x = CGFloat(item) * (itemSize.width + spacing)
            attributes.frame = CGRect(x: x, y: 0, width: itemSize.width, height: itemSize.height)
            
            // Calculate distance from center
            let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
            let cellCenter = x + itemSize.width / 2
            let distance = cellCenter - centerX  // Removed abs() to keep direction
            
            // Calculate vertical offset based on distance from center
            // Maximum vertical offset (how high the cards go)
            let maxVerticalOffset: CGFloat = -100
            
            // Calculate vertical offset using a parabolic function
            let normalizedDistance = abs(distance) / itemSize.width
            let verticalOffset = maxVerticalOffset * normalizedDistance * normalizedDistance
            
            // Create transform
            var transform = CGAffineTransform.identity
            
            // Scale based on distance
            let scale = max(0.8, 1 - abs(distance) / itemSize.width * 0.2)
            transform = transform.scaledBy(x: scale, y: scale)
            
            // Translate up based on distance from center
            transform = transform.translatedBy(x: 0, y: -verticalOffset)
            
            // Apply transforms
            attributes.transform = transform
            attributes.alpha = max(0.5, 1 - abs(distance) / itemSize.width * 0.5)
            
            // Z-index
            if abs(distance) < itemSize.width / 2 {
                attributes.zIndex = 100
            } else {
                attributes.zIndex = -Int(abs(distance))
            }
            
            cache.append(attributes)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


// MARK: - Cell
class CarouselCell: UICollectionViewCell {
    static let identifier = "CarouselCell"
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial) // Use .light, .dark, or .systemMaterial based on preference
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Set up the frosted glass effect
        contentView.addSubview(blurEffectView)
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Add the label on top of the blur effect
        blurEffectView.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: blurEffectView.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: blurEffectView.contentView.centerYAnchor)
        ])
    }

    func configure(with zIndex: Double) {
        label.text = String(format: "z: %.1f", zIndex)
    }
}

// MARK: - View Controller
class CarouselViewController: UIViewController {
    private let cellSize = CGSize(width: 280, height: 250)
    private var spacing: CGFloat = -100 {
        didSet {
            // Update layout when spacing changes
            if let layout = collectionView.collectionViewLayout as? CarouselLayout {
                layout.spacing = spacing
                layout.invalidateLayout()
            }
        }
    }
    
    // Add controls
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "gear", withConfiguration: config), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleSettings), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    private lazy var spacingSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -150
        slider.maximumValue = 0
        slider.value = Float(spacing)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(spacingChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var spacingLabel: UILabel = {
        let label = UILabel()
        label.text = "Spacing"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSettings()
    }
    
    private func setupSettings() {
        view.addSubview(settingsButton)
        view.addSubview(settingsView)
        
        settingsView.addSubview(spacingLabel)
        settingsView.addSubview(spacingSlider)
        
        NSLayoutConstraint.activate([
            // Settings button
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            // Settings view
            settingsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsView.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -20),
            settingsView.widthAnchor.constraint(equalToConstant: 280),
            
            // Controls within settings view
            spacingLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: 16),
            spacingLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 16),
            
            spacingSlider.topAnchor.constraint(equalTo: spacingLabel.bottomAnchor, constant: 8),
            spacingSlider.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: 16),
            spacingSlider.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -16),
            spacingSlider.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func toggleSettings() {
        let isHidden = !settingsView.isHidden
        if isHidden {
            // Hiding the settings
            UIView.animate(withDuration: 0.3) {
                self.settingsView.alpha = 0
                self.settingsButton.transform = .identity
            } completion: { _ in
                self.settingsView.isHidden = true
            }
        } else {
            // Showing the settings
            settingsView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.settingsView.alpha = 1
                self.settingsButton.transform = CGAffineTransform(rotationAngle: .pi/4)
            }
        }
    }
    
    @objc private func spacingChanged(_ slider: UISlider) {
        spacing = CGFloat(slider.value)
    }
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: CarouselLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.decelerationRate = .fast
        cv.showsHorizontalScrollIndicator = false
        cv.clipsToBounds = false  // Allow cells to overflow bounds
        cv.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private func setupUI() {
        view.clipsToBounds = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: cellSize.height + 60)
        ])
        
        let horizontalInset = (view.bounds.width - cellSize.width) / 2
        collectionView.contentInset = UIEdgeInsets(top: 30, left: horizontalInset, bottom: 30, right: horizontalInset)
    }
    
}

// MARK: - Collection View Data Source & Delegate
extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.identifier, for: indexPath) as! CarouselCell
        
        // Retrieve layout attributes for this item to get the z-index
        if let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) {
            cell.configure(with: Double(layoutAttributes.zIndex))
        }
        
        return cell
    }
}

extension CarouselViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemWidth = cellSize.width + spacing
        let targetOffset = targetContentOffset.pointee.x + scrollView.contentInset.left
        let targetIndex = round(targetOffset / itemWidth)
        
        targetContentOffset.pointee.x = targetIndex * itemWidth - scrollView.contentInset.left
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - SwiftUI Wrapper
struct CarouselView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CarouselViewController {
        return CarouselViewController()
    }
    
    func updateUIViewController(_ uiViewController: CarouselViewController, context: Context) {}
}

// MARK: - Preview
struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView()
    }
}
