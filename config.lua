Config = {}
Config.Zones = {
    Pos = vector3(-2161.5, -567.6, 12.1),
    PosArea = 65,
    DurationGetReward = 100, -- only second
    ItemRequires = {
        ItemUse = "afktool_a",
        ItemRemove = "afk_a"
    },
    ItemsRewards = {
        [1] = {
            Name = "afk_b",
            Label = "ปลาซาบะ",
            Amount = {1, 1},
            Percent = 100
        },
        [2] = {
            Name = "afk_c",
            Label = "ปลาแซลม่อน",
            Amount = {1, 1},
            Percent = 20
        },
        [3] = {
            Name = "afk_d",
            Label = "ปลาหยุด",
            Amount = {1, 1},
            Percent = 3
        }
    }
}
