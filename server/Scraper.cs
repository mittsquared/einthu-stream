using System;
using System.Linq;
using AngleSharp.Dom;

namespace EinthuStream {
  public static class Scraper {
    private const double RoundTo = 0.5;

    private static string NormalizeLink(string link) {
      if (link == null) return null;
      if (link.StartsWith("//")) return $"https:{link}";
      if (link.StartsWith("/")) return $"https://einthusan.tv{link}";
      return link;
    }

    public static Result ScrapeAsync(IElement parent) {
      var yearLang = parent.QuerySelector(".block2 .info > p")?.TextContent;
      var prof = parent.QuerySelectorAll(".block2 .professionals > div").Select(_ => {
        var name = _.QuerySelector(".prof p")?.TextContent;
        var role = _.QuerySelector(".prof label")?.TextContent;
        var pic = _.QuerySelector(".imgwrap img")?.GetAttribute("src");
        if (pic == "//s3.amazonaws.com/einthusanthunderbolt/etc/img/default-img.png")
          pic = null;
        return new Result.Professional {
          Name = name,
          Avatar = NormalizeLink(pic),
          Role = role
        };
      }).ToList();
      var extras = parent.QuerySelectorAll(".block3 .extras a")?.Select(_ => _.GetAttribute("href")).ToArray();

      var rating = parent.QuerySelectorAll(".block3 .average-rating p")
        ?.Select(_ => double.Parse(_.GetAttribute("data-value"))).ToArray();
      var avgRating = 0.0;
      var genre = Result.Type.Unknown;
      if (rating != null && rating.Length != 0) {
        var avg = (rating[3] + rating[4]) / 2;
        avgRating = Math.Round(avg / RoundTo) * RoundTo;

        var gIdx = 0;
        for (var i = 1; i < 3; ++i)
          if (rating[i] > rating[gIdx])
            gIdx = i;

        genre = (Result.Type) gIdx;
      }

      var url = parent.QuerySelector(".block2 .title")?.GetAttribute("href");
      var desc = parent.QuerySelector(".block2 .synopsis")?.TextContent;
      var pop = parent.QuerySelector(".block2 .title .popular") != null;
      var lang = yearLang?.Substring(4);
      var img = parent.QuerySelector(".block1 img")?.GetAttribute("src");
      var cc = parent.QuerySelector(".block2 .info p.cc") != null;
      var q = parent.QuerySelectorAll(".block2 .info > i")?.Select(_ => _.ClassName).ToList();
      var title = parent.QuerySelector(".block2 .title > h3")?.TextContent;
      var trailer = extras?[1];
      var wiki = extras?[0];
      var year = int.Parse(yearLang?.Substring(0, 4)!);

      return new Result {
        CoverImageUrl = NormalizeLink(img),
        Description = desc,
        HasSubtitles = cc,
        IsPopular = pop,
        Language = lang,
        Id = Result.GetIdFromUrl(url),
        Professionals = prof,
        Qualities = q,
        Rating = avgRating,
        Title = title,
        Genre = genre,
        Trailer = NormalizeLink(trailer),
        Wiki = NormalizeLink(wiki),
        Year = year
      };
    }

    public static Result ScrapePopularAsync(IElement parent) {
      var yearLang = parent.QuerySelector(".block2 .info > p")?.TextContent;
      var prof = parent.QuerySelectorAll(".block2 .professionals > div").Select(_ => {
        var name = _.QuerySelector("div p")?.TextContent;
        var role = _.QuerySelector("div label")?.TextContent;
        var pic = _.QuerySelector("img")?.GetAttribute("src");
        if (pic == "//s3.amazonaws.com/einthusanthunderbolt/etc/img/default-img.png")
          pic = null;
        return new Result.Professional {
          Name = name,
          Avatar = NormalizeLink(pic),
          Role = role
        };
      }).ToList();
      var extras = parent.QuerySelectorAll(".block2 .extras a")?.Select(_ => _.GetAttribute("href")).ToArray();

      var rating = parent.QuerySelectorAll(".block2 .average-rating p")
        ?.Select(_ => double.Parse(_.GetAttribute("data-value"))).ToArray();
      var avgRating = 0.0;
      var genre = Result.Type.Unknown;
      if (rating != null && rating.Length != 0) {
        var avg = (rating[3] + rating[4]) / 2;
        avgRating = Math.Round(avg / RoundTo) * RoundTo;

        var gIdx = 0;
        for (var i = 1; i < 3; ++i)
          if (rating[i] > rating[gIdx])
            gIdx = i;

        genre = (Result.Type) gIdx;
      }

      var url = parent.QuerySelector(".block2 .title")?.GetAttribute("href");
      // var desc = parent.QuerySelector(".block2 .synopsis")?.TextContent;
      // var pop = parent.QuerySelector(".block2 .title .popular") != null;
      var lang = yearLang?.Substring(4);
      var img = parent.QuerySelector(".block1 img")?.GetAttribute("src");
      var cc = parent.QuerySelector(".block1 .film-cert p.cc") != null;
      var q = parent.QuerySelectorAll(".block2 .info > i")?.Select(_ => _.ClassName).ToList();
      var title = parent.QuerySelector(".block2 .title > h2")?.TextContent;
      var trailer = extras?[1];
      var wiki = extras?[0];
      var year = int.Parse(yearLang?.Substring(0, 4)!);
      return new Result {
        CoverImageUrl = NormalizeLink(img),
        Description = null,
        HasSubtitles = cc,
        IsPopular = true,
        Language = lang,
        Id = Result.GetIdFromUrl(url),
        Professionals = prof,
        Qualities = q,
        Rating = avgRating,
        Title = title,
        Genre = genre,
        Trailer = NormalizeLink(trailer),
        Wiki = NormalizeLink(wiki),
        Year = year
      };
    }
  }
}
