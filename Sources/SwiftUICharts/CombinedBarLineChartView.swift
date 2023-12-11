//
//  CombinedBarLineChartView.swift
//  SwiftUICharts
//
//  Created by J.C. Subida on 10/25/23.
//

import SwiftUI

/// Type that defines a bar line chart style.
public struct CombinedBarLineChartStyle: ChartStyle {
    /// Minimal height for a bar-line chart view
    public let minHeight: CGFloat
    /// Boolean value indicating whenever show chart axis
    public let showAxis: Bool
    /// Leading padding for the value axis displayed in the chart
    public let axisLeadingPadding: CGFloat
    /// Boolean value indicating whenever show chart labels
    public let showLabels: Bool
    /// The count of labels that should be shown below the chart. Nil value shows all the labels.
    public let labelCount: Int?
    public let showLegends: Bool
    
    /// Type that defines the style of line drawing.
    public enum Drawing {
        case fill
        case stroke(width: CGFloat = 1)
    }
    
    /// Value that controls type of drawing.
    public let drawing: Drawing
    
    /// The max value displayed on the y-axis
    public let maxY: Double?
    
    /**
     Creates new bar chart style with the following parameters.
     
     - Parameters:
     - minHeight: The minimal height for the bar or line that presents the biggest value. Default is 100.
     - showAxis: Bool value that controls whenever to show axis.
     - axisLeadingPadding: Leading padding for axis line. Default is 0.
     - showLabels: Bool value that controls whenever to show labels.
     - labelCount: The count of labels that should be shown below the chart. Default is all.
     - showLegends: Bool value that controls whenever to show legends.
     - drawing: Value that controls type of drawing. Default is fill.
     */
#if os(watchOS)
    public init(
        minHeight: CGFloat = 50,
        showAxis: Bool = true,
        axisLeadingPadding: CGFloat = 0,
        showLabels: Bool = true,
        labelCount: Int? = nil,
        showLegends: Bool = true,
        drawing: Drawing = .fill,
        maxY: Double? = nil
    ) {
        self.minHeight = minHeight
        self.showAxis = showAxis
        self.axisLeadingPadding = axisLeadingPadding
        self.showLabels = showLabels
        self.labelCount = labelCount
        self.showLegends = showLegends
        self.drawing = drawing
        self.maxY = nil
    }
#else
    public init(
        minHeight: CGFloat = 100,
        showAxis: Bool = true,
        axisLeadingPadding: CGFloat = 0,
        showLabels: Bool = true,
        labelCount: Int? = nil,
        showLegends: Bool = true,
        drawing: Drawing = .fill,
        maxY: Double? = nil
    ) {
        self.minHeight = minHeight
        self.showAxis = showAxis
        self.axisLeadingPadding = axisLeadingPadding
        self.showLabels = showLabels
        self.labelCount = labelCount
        self.showLegends = showLegends
        self.drawing = drawing
        self.maxY = maxY
    }
#endif
}

/// SwiftUI view that draws a line chart on top of a bar chart
public struct CombinedBarLineChartView: View {
    @Environment(\.chartStyle) var chartStyle
    let barDataPoints: [DataPoint]
    let lineDataPoints: [DataPoint]
    let limit: DataPoint?
    
    /**
     Creates new line chart view with the following parameters.
     
     - Parameters:
     - dataPoints: The array of data points that will be used to draw the bar chart.
     */
    public init(barDataPoints: [DataPoint], lineDataPoints: [DataPoint], limit: DataPoint? = nil) {
        self.barDataPoints = barDataPoints
        self.lineDataPoints = lineDataPoints
        self.limit = limit
    }
    
    private var style: CombinedBarLineChartStyle {
        (chartStyle as? CombinedBarLineChartStyle) ?? .init()
    }
    
    private var gradient: LinearGradient {
        let colors = lineDataPoints.map(\.legend).map(\.color)
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var grid: some View {
        ChartGrid()
            .stroke(
                style.showAxis ? Color.secondary : .clear,
                style: StrokeStyle(
                    lineWidth: 1,
                    lineCap: .round,
                    lineJoin: .round,
                    miterLimit: 0,
                    dash: [1, 8],
                    dashPhase: 1
                )
            )
    }
    public var body: some View {
        VStack {
            HStack(spacing: 0) {
                VStack {
                    ZStack {
                        BarsView(dataPoints: barDataPoints, limit: limit, showAxis: false, maxY: style.maxY)
                        
                        if case let CombinedBarLineChartStyle.Drawing.stroke(width) = style.drawing {
                            LineChartShape(dataPoints: lineDataPoints, closePath: false)
                                .stroke(gradient, style: .init(lineWidth: width))
                        } else {
                            LineChartShape(dataPoints: lineDataPoints, closePath: true)
                                .fill(gradient)
                        }
                    }
                    .frame(minHeight: style.minHeight)
                    .background(grid)
                    
                    if style.showLabels {
                        LabelsView(
                            dataPoints: barDataPoints,
                            labelCount: style.labelCount ?? barDataPoints.count
                        ).accessibilityHidden(true)
                    }
                }
                if style.showAxis {
                    AxisView(dataPoints: barDataPoints)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityHidden(true)
                        .padding(.leading, style.axisLeadingPadding)
                }
            }
            
            if style.showLegends {
                LegendView(dataPoints: limit.map { [$0] + barDataPoints} ?? barDataPoints)
                    .padding()
                    .accessibilityHidden(true)
            }
        }
    }
}

#if DEBUG
#Preview {
    CombinedBarLineChartView(barDataPoints: DataPoint.mock, lineDataPoints: DataPoint.mock)
        .chartStyle(CombinedBarLineChartStyle(showAxis: true, showLabels: true, showLegends: false, drawing: .stroke(width: 4.0)))
}
#endif
