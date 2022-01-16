//
//  AgentsEditor.swift
//  GameplayKitAgents
//
//  Created by Simon Gladman on 19/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class AgentsEditor: UIStackView
{
    let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
    let resetButton = UIButton()
    
    weak var delegate: AgentsEditorDelegate?
    
    required init(namedGoals: [NamedGoal])
    {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.lightGray
        
        addArrangedSubview(tableView)
        
        tableView.register(AgentsEditorItemRenderer.self,
            forCellReuseIdentifier: "AgentsEditorItemRenderer")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isScrollEnabled = false
        
        tableView.rowHeight = 75
        
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(UIColor.blue, for: .normal)
        resetButton.addTarget(self, action: #selector(resetClickHandler), for: .touchDown)
        
        addArrangedSubview(resetButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var namedGoals: [NamedGoal]?
    {
        didSet
        {
            tableView.reloadData()
        }
    }
    
    @objc func resetClickHandler()
    {
        delegate?.resetAgents()
    }
    
    @objc func sliderChangeHandler(slider: SliderWithNamedGoal)
    {
        if let namedGoal = slider.namedGoal
        {
            delegate?.goalWeightDidChange(namedGoal: namedGoal)
        }
    }
    
    override func layoutSubviews()
    {
        axis = NSLayoutConstraint.Axis.vertical
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 110)
    }
    
    
}

extension AgentsEditor: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namedGoals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgentsEditorItemRenderer",
                                                 for: indexPath as IndexPath) as! AgentsEditorItemRenderer
        
        cell.namedGoal = namedGoals?[indexPath.item]
        
        cell.slider.addTarget(self, action: #selector(sliderChangeHandler(slider:)), for: .valueChanged)
        
        return cell
    }
}

extension AgentsEditor: UITableViewDelegate
{
    private func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
}

public protocol AgentsEditorDelegate: AnyObject
{
    func goalWeightDidChange(namedGoal: NamedGoal)
    func resetAgents()
}
