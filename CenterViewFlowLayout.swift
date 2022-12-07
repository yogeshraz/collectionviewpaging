//
//  CenterViewFlowLayout.swift
//  UICollectionViewHorizontalPaging
//
//  Created by Yogesh Raj on 01/05/21.
//

import UIKit

class CenterViewFlowLayout: UICollectionViewFlowLayout {
	
	override var collectionViewContentSize : CGSize {
		// Only support single section for now.
		// Only support Horizontal scroll
		let count = self.collectionView?.dataSource?.collectionView(self.collectionView!, numberOfItemsInSection: 0)
		let canvasSize = self.collectionView!.frame.size
		var contentSize = canvasSize
		if self.scrollDirection == UICollectionView.ScrollDirection.horizontal {
			let rowCount = Int((canvasSize.height - self.itemSize.height) / (self.itemSize.height + self.minimumInteritemSpacing) + 1)
			let columnCount = Int((canvasSize.width - self.itemSize.width) / (self.itemSize.width + self.minimumLineSpacing) + 1)
			let page = ceilf(Float(count!) / Float(rowCount * columnCount))
			contentSize.width = CGFloat(page) * canvasSize.width
		}
		return contentSize
	}
	
	func frameForItemAtIndexPath(_ indexPath: IndexPath) -> CGRect {
		let canvasSize = self.collectionView!.frame.size
		let rowCount = Int((canvasSize.height - self.itemSize.height) / (self.itemSize.height + self.minimumInteritemSpacing) + 1)
		let columnCount = Int((canvasSize.width - self.itemSize.width) / (self.itemSize.width + self.minimumLineSpacing) + 1)
		
		let pageMarginX = (canvasSize.width - CGFloat(columnCount) * self.itemSize.width - (columnCount > 1 ? CGFloat(columnCount - 1) * self.minimumLineSpacing : 0)) / 2.0
		let pageMarginY = (canvasSize.height - CGFloat(rowCount) * self.itemSize.height - (rowCount > 1 ? CGFloat(rowCount - 1) * self.minimumInteritemSpacing : 0)) / 2.0
		
		let page = Int(CGFloat(indexPath.row) / CGFloat(rowCount * columnCount))
		let remainder = Int(CGFloat(indexPath.row) - CGFloat(page) * CGFloat(rowCount * columnCount))
		let row = Int(CGFloat(remainder) / CGFloat(columnCount))
		let column = Int(CGFloat(remainder) - CGFloat(row) * CGFloat(columnCount))
		
		var cellFrame = CGRect.zero
		cellFrame.origin.x = pageMarginX + CGFloat(column) * (self.itemSize.width + self.minimumLineSpacing)
		cellFrame.origin.y = pageMarginY + CGFloat(row) * (self.itemSize.height + self.minimumInteritemSpacing)
		cellFrame.size.width = self.itemSize.width
		cellFrame.size.height = self.itemSize.height
		
		if self.scrollDirection == UICollectionView.ScrollDirection.horizontal {
			cellFrame.origin.x += CGFloat(page) * canvasSize.width
		}
		
		return cellFrame
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attr = super.layoutAttributesForItem(at: indexPath)?.copy() as! UICollectionViewLayoutAttributes?
		attr!.frame = self.frameForItemAtIndexPath(indexPath)
		return attr
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let originAttrs = super.layoutAttributesForElements(in: rect)
		var attrs: [UICollectionViewLayoutAttributes]? = Array<UICollectionViewLayoutAttributes>()
		
		for attr in originAttrs! {
			let idxPath = attr.indexPath
			let itemFrame = self.frameForItemAtIndexPath(idxPath)
			if itemFrame.intersects(rect) {
				let nAttr = self.layoutAttributesForItem(at: idxPath)
				attrs?.append(nAttr!)
			}
		}
		
		return attrs
	}
	
}


func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
    let pageLeft = layout.sectionInset.left - layout.minimumLineSpacing / 2
    let contentOffsetX = scrollView.contentOffset.x
    var targetContentOffsetX = targetContentOffset.pointee.x
    if let cell = self.collectionView.visibleCells.first {
        var firstCell = cell
        self.collectionView.visibleCells.forEach { (c) in
            if c.frame.origin.x < firstCell.frame.origin.x {
                firstCell = c
            }
        }
        if let indexPath = self.collectionView.indexPath(for: firstCell) {
            let identifierX = CGFloat(indexPath.row + 1) * pageWidth + pageLeft - contentOffsetX
            if identifierX < self.collectionView.bounds.size.width / 2 {
                let targetIndex = min(self.datas.count - 1, indexPath.row + 1)
                targetContentOffsetX = pageWidth * CGFloat(targetIndex)
            } else {
                targetContentOffsetX = pageWidth * CGFloat(indexPath.row)
            }
        }
    }
    targetContentOffset.pointee.x = contentOffsetX
    scrollView.setContentOffset(CGPoint(x: targetContentOffsetX, y: targetContentOffset.pointee.y), animated: true)
}
