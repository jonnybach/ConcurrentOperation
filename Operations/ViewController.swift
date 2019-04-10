//
//  ViewController.swift
//  Operations
//
//  Created by Jonathan Bachmann on 4/9/19.
//  Copyright © 2019 Bachmann, Jonathan. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        run()
    }


    func run() {
        
        var ops: [Operation] = []
        
        let op1 = ConcurrentOperation()
        op1.name = "Op1"
        op1.lengthOfTime = 1.0
        op1.shouldSetSuccess = true
        op1.completionBlock = {
            print("Got to Op1 completion")
            if op1.success && !op1.isCancelled {
                for op in ops {
                    if op != op1 {
                        op.cancel()
                    }
                }
            }
        }
        
        let op2 = ConcurrentOperation()
        op2.name = "Op2"
        op2.lengthOfTime = 1.0
        op2.shouldSetSuccess = true
        op2.completionBlock = {
            print("Got to Op2 completion")
            if op2.success && !op2.isCancelled {
                for op in ops {
                    if op != op2 {
                        op.cancel()
                    }
                }
            }
        }
        
        let op3 = ConcurrentOperation()
        op3.name = "Op3"
        op3.lengthOfTime = 1.0
        op3.shouldSetSuccess = true
        op3.completionBlock = {
            print("Got to Op3 completion")
            if op3.success && !op2.isCancelled {
                for op in ops {
                    if op != op3 {
                        op.cancel()
                    }
                }
            }
        }
        
        op2.addDependency(op1)
        op3.addDependency(op2)
        
        ops.append(op1)
        ops.append(op2)
        ops.append(op3)
        
        let q = OperationQueue()
        q.qualityOfService = .userInitiated
        q.addOperations(ops, waitUntilFinished: true)
        
        print("Done with ops")
    }
    
    
}

class ConcurrentOperation: Operation {
    enum State: String {
        case Ready, Executing, Finished
        
        var keyPath: String {
            return "is" + rawValue
        }
    }
    
    var lengthOfTime: TimeInterval?
    var success: Bool = false
    var shouldSetSuccess: Bool = false
    
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    // MARK: Operation Overrides
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override var isExecuting: Bool {
        return state == .Executing
    }
    
    override var isFinished: Bool {
        return state == .Finished
    }
    
    override func start() {
        if isCancelled {
            state = .Finished
            return
        }
        state = .Executing
        print("Started \(self.name ?? "Op?")")
        main()
        print("Finished \(self.name ?? "Op?")")
        state = .Finished
    }

// DON"T override cancel, let the super class handle this.  The start funcion will
//  will take care of setting the operation state.
//    override func cancel() {
//        super.cancel()
//        state = .Finished
//        print("Cancelled \(self.name ?? "Op?") , isCancelled: \(self.isCancelled), isFinished: \(isFinished)")
//    }
    
    override func main() {
        let deadline = DispatchTime.now() + lengthOfTime!
        while DispatchTime.now() < deadline {
            if isCancelled { return }
            print((self.name ?? "Op?") + " ... " + self.debugDescription)
        }
        success = shouldSetSuccess
    }
}
