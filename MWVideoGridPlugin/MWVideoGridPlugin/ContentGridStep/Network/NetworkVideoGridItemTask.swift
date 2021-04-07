//
//  NetworkVideoGridItemTask.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 05/01/2021.
//

import Foundation
import MobileWorkflowCore

public struct NetworkVideoGridItemTask: CredentializedAsyncTask, URLAsyncTaskConvertible {
    public typealias Response = [VideoGridStepItem]
    public let input: URL
    public let credential: Credential?
}
