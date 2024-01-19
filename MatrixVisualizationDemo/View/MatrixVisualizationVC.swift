//
//  MatrixVisualizationVC.swift
//  MatrixVisualizationDemo
//
//  Created by Vivek Parmar on 2024-01-19.
//

import UIKit

class MatrixVisualizationVC: UIViewController {

    // View's
    let collectionView: UICollectionView = {
        let layout = CustomFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(MatrixBoxCell.self, forCellWithReuseIdentifier: MatrixBoxCell.identifier)
        return collectionView
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.bounces = false
        return scrollView
    }()

    let xAxisLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()

    let yAxisLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        return stackView
    }()

    var matrixData: [DayData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadJSONFromFile()
        configureSubviews()
    }

    private func configureSubviews() {
        configureYAxisLabelsStackView()
        configureXAxisLabelsStackView()
        configureCollectionView()
        view.addSubview(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }

    func loadJSONFromFile() {
        if let path = Bundle.main.path(forResource: "JsonData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                matrixData = try decoder.decode([DayData].self, from: data)
                matrixData = appendMissingHours(to: matrixData)

                matrixData.sort { (dayData1, dayData2) -> Bool in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd"

                    guard let date1 = dateFormatter.date(from: dayData1.day),
                          let date2 = dateFormatter.date(from: dayData2.day) else {
                        return false // Handle invalid dates if necessary
                    }

                    return date1 > date2
                }

                for index in 0..<matrixData.count {
                    matrixData[index].xAxisLabel = "\(index)"
                    matrixData[index].yAxisLabel = formatDateToString(matrixData[index].day, format: "dd")
                }
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
    }

    func setupXAxisLabels() {
        for hour in 0...23 {
            let label = createAxisLabel(text: "\(hour)h", width: 80, height: 40, isXAxis: true)
            xAxisLabelsStackView.addArrangedSubview(label)
        }
    }

    func setupYAxisLabels() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        for dayData in matrixData {
            let date = dateFormatter.date(from: dayData.day) ?? Date()
            let label = createAxisLabel(text: formatDate(date, format: "d"),isXAxis: false)
            yAxisLabelsStackView.addArrangedSubview(label)
        }

        let hourLabel = createAxisLabel(text: "hour",height: 40, isXAxis: false)
        yAxisLabelsStackView.insertArrangedSubview(hourLabel, at: 0)

    }

    func createAxisLabel(text: String, width: CGFloat = 80, height: CGFloat = 80, isXAxis: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        if isXAxis {
            xAxisLabelsStackView.addArrangedSubview(label)
            label.widthAnchor.constraint(equalToConstant: width).isActive = true
        } else {
            if height == 20 {
                yAxisLabelsStackView.insertArrangedSubview(label, at: 0)
            } else {
                xAxisLabelsStackView.addArrangedSubview(label)
                label.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        }

        label.heightAnchor.constraint(equalToConstant: height).isActive = true

        return label
    }


    //Function to format date
    func formatDate(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return addOrdinalSuffix(to: Int(dateFormatter.string(from: date)) ?? 0)
    }

    func addOrdinalSuffix(to number: Int) -> String {
        let suffix: String
        switch number % 10 {
        case 1 where number % 100 != 11:
            suffix = "st"
        case 2 where number % 100 != 12:
            suffix = "nd"
        case 3 where number % 100 != 13:
            suffix = "rd"
        default:
            suffix = "th"
        }

        return "\(number)\(suffix)"
    }

    func formatDateToString(_ date: String, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: date)
        }
        return ""
    }

    private func appendMissingHours(to days: [DayData]) -> [DayData] {
        var updatedData: [DayData] = []

        for day in days {
            let missingHours = generateMissingHours(for: day)
            let updatedDay = DayData(day: day.day, hours: day.hours + missingHours)
            updatedData.append(updatedDay)
        }
        return updatedData
    }

    // Function to generate missing hours with record_count set to 0
    private func generateMissingHours(for day: DayData) -> [HourData] {
        var missingHours: [HourData] = []

        let existingHourStrings = Set(day.hours.map { $0.hour })

        if existingHourStrings.count < 24 {
            for hour in existingHourStrings.count+1...24 {
                let hourString = String(format: "202304%02d", hour)

                if !existingHourStrings.contains(hourString) {
                    let missingHour = HourData(hour: hourString, recordCount: 0)
                    missingHours.append(missingHour)
                }
            }
        }
        return missingHours
    }
}

extension MatrixVisualizationVC {
    private func configureXAxisLabelsStackView() {
        scrollView.addSubview(xAxisLabelsStackView)
        setupXAxisLabels()
        xAxisLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        xAxisLabelsStackView.leadingAnchor.constraint(equalTo: yAxisLabelsStackView.trailingAnchor).isActive = true
        xAxisLabelsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        xAxisLabelsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    }

    private func configureYAxisLabelsStackView() {
        scrollView.addSubview(yAxisLabelsStackView)
        setupYAxisLabels()
        yAxisLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        yAxisLabelsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        yAxisLabelsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        yAxisLabelsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }

    private func configureCollectionView() {
        collectionView.dataSource = self
        scrollView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: yAxisLabelsStackView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: xAxisLabelsStackView.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
}

extension MatrixVisualizationVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return matrixData.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matrixData[section].hours.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatrixBoxCell.identifier, for: indexPath) as! MatrixBoxCell
        let recordCount = matrixData[indexPath.section].hours[indexPath.item].recordCount
        cell.configure(with: recordCount)
        return cell
    }
}
