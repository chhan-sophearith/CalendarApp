//
//  CalendarAppApp.swift
//  CalendarApp
//
//  Created by Chhan Sophearith  on 26/6/25.
//

import SwiftUI
import UIKit
import FSCalendar

@main
struct CalendarAppApp: App {
    var body: some Scene {
        WindowGroup {
            CalendarView()
        }
    }
}


struct CalendarView: UIViewControllerRepresentable {
    
    // Create the UIViewController (CalendarViewController)
    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController()
    }
    
    // Update the UIViewController with new data if needed
    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
        // Here, you can update any state or logic if needed.
    }
}


class CalendarViewController: UIViewController {
    
    var calendar: FSCalendar!
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    
    var monthLabel: UILabel!
    var backButton: UIButton!
    var forwardButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a container view with card-like appearance
        var calendarContainerView = UIView(frame: CGRect(x: 20, y: 50, width: view.frame.width - 40, height: 320))
        calendarContainerView.backgroundColor = .white
        calendarContainerView.layer.cornerRadius = 10
        calendarContainerView.layer.shadowColor = UIColor.black.cgColor
        calendarContainerView.layer.shadowOpacity = 0.3
        calendarContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        calendarContainerView.layer.shadowRadius = 2
        view.addSubview(calendarContainerView)
        
        
        
        // Create FSCalendar instance
        calendar = FSCalendar(frame: CGRect(x: 10, y: 70, width: calendarContainerView.frame.width - 20, height: calendarContainerView.frame.height - 100))
        
        // calendar = FSCalendar(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 300))
        
        
        calendar.today = nil
        
        calendar.allowsMultipleSelection = true
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        
        
        
        
        calendar.select(Date())
        
        
        let currentDate = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: Date())
        
        
        selectedStartDate = selectedDate
        
        calendar.headerHeight = 0
        calendar.appearance.weekdayTextColor = UIColor.black
        
        
        calendarContainerView.addSubview(calendar)
        
        //view.addSubview(calendar)
        
        // Create navigation buttons
        backButton = UIButton(type: .system)
        backButton.setTitle("<", for: .normal)
        backButton.addTarget(self, action: #selector(backwardButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        calendarContainerView.addSubview(backButton)
        
        forwardButton = UIButton(type: .system)
        forwardButton.setTitle(">", for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        forwardButton.frame = CGRect(x: calendarContainerView.frame.width - 50, y: 20, width: 40, height: 40)
        calendarContainerView.addSubview(forwardButton)
        
        // Create month label
        monthLabel = UILabel(frame: CGRect(x: 0, y: 35, width: view.frame.width - 100, height: 30))
        monthLabel.textAlignment = .center
        monthLabel.font = UIFont(name: "Poppins-Medium", size: 14.0)
        calendarContainerView.addSubview(monthLabel)
        updateMonthLabel()
    }
    
    
    
    func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: calendar.currentPage)
        monthLabel.center = CGPoint(x: view.center.x - 20, y: 35)
    }
    
    
    @objc func backwardButtonTapped() {
        
        
        let currentMonth = calendar.currentPage
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? Date()
        //   date = previousMonth
        calendar.setCurrentPage(previousMonth, animated: true)
        
        updateMonthLabel()
    }
    
    @objc func forwardButtonTapped() {
        
        let currentMonth = calendar.currentPage
        let previousMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
        // date = previousMonth
        calendar.setCurrentPage(previousMonth, animated: true)
        updateMonthLabel()
    }
    
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        
        let currentDate = Calendar.current.startOfDay(for: Date())
        let selectedDate = Calendar.current.startOfDay(for: date)
        
        
        if selectedDate < currentDate {
            
            print("Selected Date is \(date)")
            print("Today Date is \(Date())")
            print("Date is lesser then today")
            calendar.deselect(date)
            
            if(selectedStartDate != nil) {
                calendar.deselect(selectedStartDate!)
                
                let currentDate = Calendar.current.startOfDay(for: Date())
                let selectedDate = Calendar.current.startOfDay(for: Date())
                
                selectedStartDate = selectedDate
                
                calendar.select(selectedDate)
            }
            
            if(selectedEndDate != nil) {
                calendar.deselect(selectedEndDate!)
                selectedEndDate = nil
            }
            
            
            
            calendar.reloadData()
            return
        }
        
        
        // If both start and end dates are already selected, clear the previous selection
        if selectedStartDate != nil && selectedEndDate != nil {
            
            calendar.deselect(selectedStartDate!)
            calendar.deselect(selectedEndDate!)
            
            
            selectedStartDate = date
            selectedEndDate = nil
            calendar.reloadData()
            return
        }
        
        
        
        // If start date is already selected and end date is nil, set new end date
        if let startDate = selectedStartDate, selectedEndDate == nil {
            if date < startDate {
                // If end date is earlier than start date, deselect all dates and set new start date
                //calendar.today = nil
                
                calendar.deselect(startDate)
                selectedStartDate = date
                selectedEndDate = nil
            } else {
                selectedEndDate = date
            }
            calendar.reloadData()
            return
        }
        
        // If only start date is selected, set new start date
        if selectedStartDate == nil || selectedEndDate != nil {
            selectedStartDate = date
            calendar.reloadData()
            return
        }
        
        self.configureVisibleCells()
    }
    
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        guard let selectedStartDate = selectedStartDate, let selectedEndDate = selectedEndDate else {
            return 0
        }
        if date >= selectedStartDate && date <= selectedEndDate {
            return 1
        }
        return 0
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        guard let selectedStartDate = selectedStartDate, let selectedEndDate = selectedEndDate else {
            return nil
        }
        if date >= selectedStartDate && date <= selectedEndDate {
            
            return UIColor.blue.withAlphaComponent(0.2) // Highlighted color
        }
        return nil
    }
    
    //Adding below additional code for testing purpose
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! DIYCalendarCell
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        configure(cell: cell as! DIYCalendarCell, for: date, at: position)
    }
    
    private func configure(cell: DIYCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        guard let selectedStartDate = selectedStartDate else {
            cell.selectionType = .none
            
            //Adding this line for testing
            cell.titleLabel.textColor = UIColor.black
            cell.setNeedsLayout()
            return
        }
        
        if let selectedEndDate = selectedEndDate {
            if date >= selectedStartDate && date <= selectedEndDate {
                if date == selectedStartDate {
                    cell.selectionType = .leftBorder
                    cell.titleLabel.textColor = UIColor.white
                } else if date == selectedEndDate {
                    cell.selectionType = .rightBorder
                    cell.titleLabel.textColor = UIColor.white
                } else {
                    //replace it .left border and check
                    cell.selectionType = .middle
                    
                    cell.titleLabel.textColor = UIColor.white
                }
            } else {
                cell.selectionType = .none
                cell.titleLabel.textColor = UIColor.black
            }
        } else {
            //commenting it for testing
            cell.selectionType = date == selectedStartDate ? .single : .none
            
        }
        
        cell.setNeedsLayout()
    }
    
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            configure(cell: cell as! DIYCalendarCell, for: date!, at: position)
        }
    }
    
}

enum SelectionType: Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

class DIYCalendarCell: FSCalendarCell {
    
    // weak var circleImageView: UIImageView!
    weak var selectionLayer: CAShapeLayer!
    
    // commenting it for testing
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // let circleImageView = UIImageView(image: UIImage(named: "circle")!)
        
        //  let circleImageView = UIImageView(image: UIImage(systemName: "circle"))
        // circleImageView.tintColor = .blue // Set the color if needed
        
        //self.contentView.insertSubview(circleImageView, at: 0)
        //self.circleImageView = circleImageView
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.systemBlue.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        // self.shapeLayer.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // self.circleImageView.frame = self.contentView.bounds
        self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
        self.selectionLayer.frame = self.contentView.bounds
        
        switch selectionType {
        case .middle:
            self.selectionLayer.path = UIBezierPath(rect: self.selectionLayer.bounds).cgPath
        case .leftBorder:
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds,
                                                    byRoundingCorners: [.topLeft, .bottomLeft],
                                                    cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
        case .rightBorder:
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds,
                                                    byRoundingCorners: [.topRight, .bottomRight],
                                                    cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2)).cgPath
        case .single:
            let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
            self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2,
                                                                   y: self.contentView.frame.height / 2 - diameter / 2,
                                                                   width: diameter,
                                                                   height: diameter)).cgPath
        default:
            self.selectionLayer.path = nil
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        if self.isPlaceholder {
            self.eventIndicator.isHidden = true
            self.titleLabel.textColor = UIColor.lightGray
        }
    }
}
