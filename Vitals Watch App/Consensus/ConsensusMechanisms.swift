//
//  ProofOfWork.swift
//  Vitals
//
//  Created by Lekh Nath Khanal on 28/03/2025.
//

class ProofOfWork {
    
    private let difficulty: Int = 2
    private let repeatingChar: Character = "0"
    
    func validate(block: Block) {
        let targetPrefix = String(repeating: repeatingChar, count: difficulty)
        while !block.hash.hasPrefix(targetPrefix) {
            block.nonce += 1
        }
    }
}

class ProofOfAuthority {
    func validate(block: Block) -> Bool {
    //    implement POA later
    //    for now it is authorized to all nodes until it is implemented
        return true
    }

}
