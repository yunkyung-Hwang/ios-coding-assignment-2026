/// 실제 응답에서 발췌. 두 번째 상품은 brand 키가 빠진 형태
enum ProductFixture {
    static let list = """
    {
      "products": [
        {
          "id": 1,
          "title": "Essence Mascara Lash Princess",
          "description": "볼륨과 길이를 살려주는 마스카라",
          "category": "beauty",
          "price": 9.99,
          "rating": 2.56,
          "stock": 99,
          "brand": "Essence",
          "thumbnail": "https://cdn.dummyjson.com/p/1/thumbnail.webp",
          "images": ["https://cdn.dummyjson.com/p/1/1.webp"],
          "reviews": [
            { "rating": 3, "comment": "별로" },
            { "rating": 4, "comment": "만족" },
            { "rating": 5, "comment": "최고" }
          ],
          "meta": { "createdAt": "2025-10-09T14:47:01.588Z" }
        },
        {
          "id": 2,
          "title": "Eyeshadow Palette with Mirror",
          "description": "거울이 달린 아이섀도 팔레트",
          "category": "beauty",
          "price": 19.99,
          "rating": 3.28,
          "stock": 34,
          "thumbnail": "https://cdn.dummyjson.com/p/2/thumbnail.webp",
          "images": [
            "https://cdn.dummyjson.com/p/2/1.webp",
            "https://cdn.dummyjson.com/p/2/2.webp"
          ],
          "reviews": [
            { "rating": 5, "comment": "좋음" },
            { "rating": 4, "comment": "무난" },
            { "rating": 2, "comment": "아쉬움" }
          ],
          "meta": { "createdAt": "2025-04-30T09:41:02.053Z" }
        }
      ],
      "total": 194,
      "skip": 30,
      "limit": 2
    }
    """

    static let detail = """
    {
      "id": 2,
      "title": "Eyeshadow Palette with Mirror",
      "description": "거울이 달린 아이섀도 팔레트",
      "category": "beauty",
      "price": 19.99,
      "rating": 3.28,
      "stock": 34,
      "thumbnail": "https://cdn.dummyjson.com/p/2/thumbnail.webp",
      "images": [
        "https://cdn.dummyjson.com/p/2/1.webp",
        "https://cdn.dummyjson.com/p/2/2.webp"
      ],
      "reviews": [
        { "rating": 5, "comment": "좋음" },
        { "rating": 4, "comment": "무난" },
        { "rating": 2, "comment": "아쉬움" }
      ],
      "meta": { "createdAt": "2025-04-30T09:41:02.053Z" }
    }
    """

    /// 과제 명시 항목만 있는 응답. 부가 필드가 모두 빠진 형태
    static let minimal = """
    {
      "id": 3,
      "title": "Powder Canister",
      "price": 14.99,
      "thumbnail": "https://cdn.dummyjson.com/p/3/thumbnail.webp"
    }
    """

    /// 썸네일 주소를 URL 로 만들 수 없는 응답
    static let brokenThumbnail = """
    {
      "id": 4,
      "title": "Red Lipstick",
      "price": 12.99,
      "thumbnail": ""
    }
    """

    /// 사용 가능한 이미지가 없는 상세 응답
    static let detailWithoutImage = """
    {
      "id": 5,
      "title": "Mascara",
      "price": 9.99,
      "thumbnail": "https://cdn.dummyjson.com/p/5/thumbnail.webp",
      "images": [""]
    }
    """
}
