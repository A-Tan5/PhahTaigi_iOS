
import Foundation


class Poj {
    
    // [poj_unicode: poj_number]
    static let pojUnicodeToPojNumberDictionary: [String: String] = [
        // A
        "Á": "A2",
        "À": "A3",
        "Â": "A5",
        "Ǎ": "A6",
        "Ā": "A7",
        "A̍": "A8",
        "Ă": "A9",
        
        // a
        "á": "a2",
        "à": "a3",
        "â": "a5",
        "ǎ": "a6",
        "ā": "a7",
        "a̍": "a8",
        "ă": "a9",
        
        // I
        "Í": "I2",
        "Ì": "I3",
        "Î": "I5",
        "Ǐ": "I6",
        "Ī": "I7",
        "I̍": "I8",
        "Ĭ": "I9",
        
        // i
        "í": "i2",
        "ì": "i3",
        "î": "i5",
        "ǐ": "i6",
        "ī": "i7",
        "i̍": "i8",
        "ĭ": "i9",
        
        // U
        "Ú": "U2",
        "Ù": "U3",
        "Û": "U5",
        "Ǔ": "U6",
        "Ū": "U7",
        "U̍": "U8",
        "Ŭ": "U9",
        
        // u
        "ú": "u2",
        "ù": "u3",
        "û": "u5",
        "ǔ": "u6",
        "ū": "u7",
        "u̍": "u8",
        "ŭ": "u9",
        
        // E
        "É": "E2",
        "È": "E3",
        "Ê": "E5",
        "Ě": "E6",
        "Ē": "E7",
        "E̍": "E8",
        "Ĕ": "E9",
        
        // e
        "é": "e2",
        "è": "e3",
        "ê": "e5",
        "ě": "e6",
        "ē": "e7",
        "e̍": "e8",
        "ĕ": "e9",
        
        // O
        "Ó": "O2",
        "Ò": "O3",
        "Ô": "O5",
        "Ǒ": "O6",
        "Ō": "O7",
        "O̍": "O8",
        "Ŏ": "O9",
        
        // o
        "ó": "o2",
        "ò": "o3",
        "ô": "o5",
        "ǒ": "o6",
        "ō": "o7",
        "o̍": "o8",
        "ŏ": "o9",
        
        // O͘
        "O\u{0358}": "OO",
        "Ó\u{0358}": "OO2",
        "Ò\u{0358}": "OO3",
        "Ô\u{0358}": "OO5",
        "Ǒ\u{0358}": "OO6",
        "Ō\u{0358}": "OO7",
        "O̍\u{0358}": "OO8",
        "Ŏ\u{0358}": "OO9",
        
        // o͘
        "o\u{0358}": "oo",
        "ó\u{0358}": "oo2",
        "ò\u{0358}": "oo3",
        "ô\u{0358}": "oo5",
        "ǒ\u{0358}": "oo6",
        "ō\u{0358}": "oo7",
        "o̍\u{0358}": "oo8",
        "ŏ\u{0358}": "oo9",
        
        // M
        "Ḿ": "M2",
        "M̀": "M3",
        "M̂": "M5",
        "M̌": "M6",
        "M̄": "M7",
        "M̍": "M8",
        "M̋": "M9",
        
        // m
        "ḿ": "m2",
        "m̀": "m3",
        "m̂": "m5",
        "m̌": "m6",
        "m̄": "m7",
        "m̍": "m8",
        "m̋": "m9",
        
        // N
        "Ń": "N2",
        "Ǹ": "N3",
        "N̂": "N5",
        "Ň": "N6",
        "N̄": "N7",
        "N̍": "N8",
        "N̋": "N9",
        
        // n
        "ń": "n2",
        "ǹ": "n3",
        "n̂": "n5",
        "ň": "n6",
        "n̄": "n7",
        "n̍": "n8",
        "n̋": "n9",
        
        // Ng
        "Ńg": "Ng2",
        "Ǹg": "Ng3",
        "N̂g": "Ng5",
        "Ňg": "Ng6",
        "N̄g": "Ng7",
        "N̍g": "Ng8",
        "N̋g": "Ng9",
        
        // NG
        "ŃG": "NG2",
        "ǸG": "NG3",
        "N̂G": "NG5",
        "ŇG": "NG6",
        "N̄G": "NG7",
        "N̍G": "NG8",
        "N̋G": "NG9",
        
        // ng
        "ńg": "ng2",
        "ǹg": "ng3",
        "n̂g": "ng5",
        "ňg": "ng6",
        "n̄g": "ng7",
        "n̍g": "ng8",
        "n̋g": "ng9",
    ]
    
    // <poj_number: poj_unicode>
    static let pojNumberToPojUnicodeDictionary: [String: String] = {
        var dict = [String: String]()
        
        for (key, value) in pojUnicodeToPojNumberDictionary {
            dict[value] = key
        }
        
        return dict
    }()

}
