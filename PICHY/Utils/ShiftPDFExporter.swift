//
//  ShiftPDFExporter.swift
//  PICHY
//
//  Renders a one-page A4 PDF of a month's shift schedule for sharing/printing.
//

import UIKit

enum ShiftPDFExporter {
    private static let pageWidth: CGFloat = 595   // A4 @ 72dpi
    private static let pageHeight: CGFloat = 842
    private static let margin: CGFloat = 40

    /// Builds the PDF and writes it to a temporary file, returning its URL.
    /// Returns nil if the file can't be written.
    static func export(month: Date,
                       shifts: [Shift],
                       rates: PayRates,
                       profile: UserProfile) -> URL? {
        let cal = Calendar.gregorian
        let monthShifts = shifts
            .filter {
                let a = cal.dateComponents([.year, .month], from: $0.date)
                let b = cal.dateComponents([.year, .month], from: month)
                return a.year == b.year && a.month == b.month
            }
            .sorted { $0.date < $1.date }

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y = margin
            y = drawHeader(month: month, profile: profile, at: y)
            y += 12
            y = drawColumnTitles(at: y)
            var total = 0
            for shift in monthShifts {
                if y > pageHeight - margin - 60 {
                    ctx.beginPage()
                    y = margin
                    y = drawColumnTitles(at: y)
                }
                let income = shift.income(using: rates)
                total += income
                y = drawRow(shift: shift, income: income, at: y, cal: cal)
            }
            drawTotal(total, count: monthShifts.count, at: y + 10)
        }

        let name = "PICHY-ตารางเวร-\(BuddhistCalendar.monthYearLong(month)).pdf"
            .replacingOccurrences(of: " ", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Drawing

    private static func drawHeader(month: Date, profile: UserProfile, at y: CGFloat) -> CGFloat {
        let title = "ตารางเวร \(BuddhistCalendar.monthYearLong(month))"
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor(red: 0.91, green: 0.65, blue: 0.25, alpha: 1)
        ])

        let who = [profile.name, profile.role, profile.hospital]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        if !who.isEmpty {
            who.draw(at: CGPoint(x: margin, y: y + 30), withAttributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ])
            return y + 50
        }
        return y + 30
    }

    private static func drawColumnTitles(at y: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        "วันที่".draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        "ประเภท".draw(at: CGPoint(x: margin + 180, y: y), withAttributes: attrs)
        "รายได้".draw(at: CGPoint(x: pageWidth - margin - 90, y: y), withAttributes: attrs)
        drawSeparator(at: y + 18)
        return y + 26
    }

    private static func drawRow(shift: Shift, income: Int, at y: CGFloat, cal: Calendar) -> CGFloat {
        let rowAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        BuddhistCalendar.dateLabelMedium(shift.date)
            .draw(at: CGPoint(x: margin, y: y), withAttributes: rowAttrs)

        let typeLabel: String
        if let leave = shift.resolvedLeave {
            typeLabel = leave.label
        } else {
            typeLabel = "เวร\(shift.type.label)" + (shift.otHours > 0 ? " + OT \(shift.otHours) ชม." : "")
        }
        typeLabel.draw(at: CGPoint(x: margin + 180, y: y), withAttributes: rowAttrs)

        let incomeText = income > 0 ? CurrencyFormatter.baht(income) : "—"
        incomeText.draw(at: CGPoint(x: pageWidth - margin - 90, y: y), withAttributes: rowAttrs)
        return y + 22
    }

    private static func drawTotal(_ total: Int, count: Int, at y: CGFloat) {
        drawSeparator(at: y)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        "รวม \(count) เวร".draw(at: CGPoint(x: margin, y: y + 8), withAttributes: attrs)
        ("รายได้รวม " + CurrencyFormatter.baht(total))
            .draw(at: CGPoint(x: pageWidth - margin - 160, y: y + 8), withAttributes: attrs)
    }

    private static func drawSeparator(at y: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        UIColor(white: 0.85, alpha: 1).setStroke()
        path.lineWidth = 0.5
        path.stroke()
    }
}
