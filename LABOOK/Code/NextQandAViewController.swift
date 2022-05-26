//
//  NextQandAViewController.swift
//  LABOOK
//
//  Created by Koudai Okamura on 2022/03/02.
//

import UIKit

class NextQandAViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    

    @IBOutlet weak var NextQandAListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NextQandAListTableView.dataSource = self
        NextQandAListTableView.delegate = self
        
    }
    


}
