//
//  NetworkGridItemTask.swift
//  MWVideoGridPlugin
//
//  Created by Jonathan Flintham on 05/01/2021.
//

import Foundation
import MobileWorkflowCore

public struct NetworkGridItemTask: CredentializedAsyncTask, URLAsyncTaskConvertible {
    public typealias Response = [MWGridStepItem]
    public let input: URL
    public let credential: Credential?
}
