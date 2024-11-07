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
    private let spacing: CGFloat = -100
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let width = CGFloat(collectionView.numberOfItems(inSection: 0)) * (itemSize.width + spacing) - spacing
        return CGSize(width: width, height: itemSize.height)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        
        let horizontalOffset = (collectionView.bounds.width - itemSize.width) / 2
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let x = CGFloat(item) * (itemSize.width + spacing)
            attributes.frame = CGRect(x: x, y: 0, width: itemSize.width, height: itemSize.height)
            
            // Calculate distance from center
            let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
            let cellCenter = x + itemSize.width / 2
            let distance = abs(cellCenter - centerX)
            
            // Apply scale transform
            let scale = max(0.8, 1 - distance / itemSize.width * 0.2)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            // Apply opacity
            attributes.alpha = max(0.5, 1 - distance / itemSize.width * 0.5)
            
            // Apply z-index
            if distance < itemSize.width / 2 {
                attributes.zIndex = 100
            } else {
                attributes.zIndex = -Int(distance)
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
        contentView.backgroundColor = .gray
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.zPosition = 0
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with zIndex: Int) {
        label.text = "z: \(zIndex)"
    }
}

// MARK: - View Controller
class CarouselViewController: UIViewController {
    private let cellSize = CGSize(width: 280, height: 250)
    private let spacing: CGFloat = -100
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: CarouselLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.decelerationRate = .fast
        cv.showsHorizontalScrollIndicator = false
        cv.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.identifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: cellSize.height)
        ])
        
        let horizontalInset = (view.bounds.width - cellSize.width) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
}

// MARK: - Collection View Data Source & Delegate
extension CarouselViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.identifier, for: indexPath) as! CarouselCell
        cell.configure(with: indexPath.item)
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
