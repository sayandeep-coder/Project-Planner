import SwiftUI

struct StatTile: View {
    let value: Int
    let label: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.gradient)
                    .frame(width: 34, height: 34)
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
    }
}
