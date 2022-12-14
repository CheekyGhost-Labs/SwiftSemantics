//
//  ClosureType+Utils.swift
//  
//
//  Created by Michael O'Brien on 1/12/2022.
//

import Foundation

extension ClosureType {

    // MARK: - Internal

    func isVoidType(_ type: String?) -> Bool {
        guard let type = type else { return false }
        let voidTypes = ["Void","(Void)","Void?","(Void?)","()","(())","()?","(()?)"]
        return voidTypes.contains(type)
    }
}
