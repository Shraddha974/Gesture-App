//
//  GlassesStyle.swift
//  GestureApp
//
//  Created by Shraddha on 21/01/26.
//

import SwiftUI


enum GlassesStyle: String, CaseIterable, Identifiable {
    case astro
    case alien
    case pineapple
   
    case cosmo
    case funtime
    case heart
    case galaxy
    
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .astro:
            return "astro"
        case .alien:
            return "astro1"
        case .pineapple:
            return "pineapple"
       
        case .cosmo:
            return "astro3"
        case .funtime:
            return "astro4"
        case .heart:
            return "heart"
        case .galaxy:
            return "astro2"
        
        }
    }
}


enum HatStyle: String, CaseIterable, Identifiable {
    case hat, classic, jack, birthday, bird, spring, paper
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .hat:
            return "hat"
        case .classic:
            return "classic"
        case .jack:
            return "jack"
        case .birthday:
            return "birthday"
        case .bird:
            return "bird"
        case .spring:
            return "spring"
        case .paper:
            return "paper"
        }
    }
}


enum HairStyle: String, CaseIterable, Identifiable {
    case japanese, clown, blue, pink, curly, golden
    var id: String { rawValue }
    
    var imageName: String {
        switch self {
        case .japanese:
            return "japanese"
        case .clown:
            return "clown"
        case .blue:
            return "blue"
        case .pink:
            return "pink"
        case .curly:
            return "curly"
        case .golden:
            return "golden"
        }
    }
}


enum BeardStyle: String, CaseIterable, Identifiable {
    case pirate
    case glitter
   // case blackM
    case brown
    case rainbow
    case goldenB
   // case batman
    case triangle
    case icy
    case warrior

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .pirate: return "black"
        case .glitter: return "glitter"
      //  case .blackM: return "blackM"
        case .brown: return "brown"
        case .rainbow: return "rainbow"
        case .goldenB: return "goldenB"
       // case .batman: return "batman"
        case .triangle: return "triangle"
        case .icy: return "icy"
        case .warrior:return "pirate"
        }
    }
}

enum PagadiStyle: String, CaseIterable, Identifiable {
    case marathi, rajasthani, himachali, mysore,pagadi, mukut
    
    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .marathi: return "marathi"
      
        case .rajasthani:
            return "rajasthani"
        case .himachali:
            return  "himachali"
        case .mysore:
            return  "mysore"
//        case .jack:
//            return  "jack"
        case .pagadi:
            return  "pagadi"
        case .mukut:
            return "mukut"
        }
    }
}



enum NoseRingStyle: String, CaseIterable, Identifiable {
    case noseRing
    
    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .noseRing: return "noseRing"
      
        }
    }
}
