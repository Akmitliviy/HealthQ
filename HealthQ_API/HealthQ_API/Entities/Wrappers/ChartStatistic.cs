using HealthQ_API.DTOs;

namespace HealthQ_API.Entities.Wrappers;

public class ChartStatistic
{
    public required IEnumerable<ChartData> ChartsData { get; set; } = new List<ChartData>();
    public required double ValueSum { get; set; }
}