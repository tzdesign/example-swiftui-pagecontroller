//
//  WeekView.swift
//  SwiftUIPageViewController
//
//  Created by Tobias Zimmermann on 07.12.23.
//

import SwiftUI
import UIKit


// SwiftUI is here with the incoming date

struct WeekView: View {
    var date : Date
    var body: some View {
        VStack{
            Text("Hello, World!").font(.title).foregroundStyle(Color(hue: .random(in: 0...1), saturation: 1, brightness: 1))
           Text(firstDayOfWeek,style:.date)
           Text(lastDayOfWeek,style:.date)
        }
        
    }
    
    var firstDayOfWeek : Date{
        let comps = Calendar.current.dateComponents([.weekOfYear,.yearForWeekOfYear], from: date)
        return Calendar.current.date(from: comps) ?? date
    }
    var lastDayOfWeek : Date{
        Calendar.current.date(byAdding: .day, value: 7, to: firstDayOfWeek) ?? date
    }
}



// This is the view to use from the outside

struct WeekPageView : View{
    
    @State var date = Date()
    var body: some View{
        WeekPageViewControllerRepresentable(date: $date)
    }
    
    
}


// This is the hosting controller which is necessary for the page view controller as it only work with UIKit controller

class WeekViewController : UIHostingController<WeekView>{
    
    var date : Date
    
    init(date : Date,pageViewController:WeekPageViewController){
        self.date = date
        super.init(rootView: WeekView(date: date))
        
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// This is the representation for the page view controller to use it in WeekPageView (SwiftUI context)

struct WeekPageViewControllerRepresentable: UIViewControllerRepresentable {

    
    @Binding var date : Date
    
    func makeUIViewController(context: Context) -> WeekPageViewController {
        let vc = WeekPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.date = date
        return vc
    }

    func updateUIViewController(_ uiViewController: WeekPageViewController, context: Context) {
        uiViewController.show(date)
    }
}

// This is the good old UIKit Page View controller

class WeekPageViewController: UIPageViewController{
    
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
         _ = becomeFirstResponder()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if let lastController = self.viewControllers?.last{
            self.setViewControllers([lastController], direction: .reverse, animated: false, completion: nil)
        }
        else{
            show(date)
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    
    func show(_ date:Date){
        var direction : UIPageViewController.NavigationDirection = .reverse
        
        if let controller = self.viewControllers, let first =  controller.first as? WeekViewController{
            
            direction = first.date.compare(date) == .orderedDescending ? .reverse : .forward
                        
            if date == first.date{
                return
            }
            
        }
        
        
        self.setViewControllers([self.pageViewController(for:date)], direction: direction, animated: true, completion: nil)
        
    }
    
    
    
    
}

// This is the page controller data source

extension WeekPageViewController : UIPageViewControllerDataSource{
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let controller = viewController as? WeekViewController else { return nil }
        guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: controller.date) else { return nil}
        return self.pageViewController(for: newDate)
        
        
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let controller = viewController as? WeekViewController else { return nil }
        guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: controller.date) else { return nil}
        
        return self.pageViewController(for: newDate)
        
    }
    
    func pageViewController(for date: Date) -> WeekViewController {
        
        return WeekViewController(date: date, pageViewController: self)
        
        
    }
}


#Preview {
    WeekPageView()
}
