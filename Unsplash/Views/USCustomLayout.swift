//
//  USCustomLayout.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 20/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import UIKit

protocol USCustomLayoutDelegate: AnyObject {
  func collectionView( _ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

final class USCustomLayout: UICollectionViewLayout {
    typealias Constants = USConstants.Main

    weak var delegate: USCustomLayoutDelegate?

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth,
                      height: contentHeight)
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else {
            return
        }

        let columnWidth = contentWidth / CGFloat(Constants.numberOfColumn)
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: Constants.numberOfColumn)
        var xOffset: [CGFloat] = []

        for column in 0..<Constants.numberOfColumn {
          xOffset.append(CGFloat(column) * columnWidth)
        }

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            // swiftlint:disable:next line_length
            let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) ?? Constants.defaultCellHeight

            let height = (Constants.cellPadding * 2) + photoHeight

            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: height)

            let insetFrame = frame.insetBy(dx: Constants.cellPadding, dy: Constants.cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame

            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)

            yOffset[column] = yOffset[column] + height

            column = column < (Constants.numberOfColumn - 1) ? (column + 1) : 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)

        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in cache {
          if attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
          }
        }

        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForItem(at: indexPath)

        return cache[indexPath.item]
    }
}
