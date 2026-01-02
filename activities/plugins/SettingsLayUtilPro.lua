local bindClass = luajava.bindClass
local itemsLay=SettingsLayUtil.itemsLay
local oldLastIndex=SettingsLayUtil.itemsNumber
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
SettingsLayUtil.ITEM_AVATAR_SWITCH=oldLastIndex+1
SettingsLayUtil.ITEM_AVATAR_ICON_SWITCH=oldLastIndex+2
SettingsLayUtil.itemsNumber=oldLastIndex+2

local infoLay={
  AppCompatImageView;
  padding="8dp";
  id="infoBtnView";
  layout_width="40dp";
  layout_height="48dp";
  src="res/drawable/ic_information_outline.png";
}

table.insert(itemsLay,{--设置项(头像,标题,简介)
  LinearLayoutCompat;
  layout_width="fill";
  gravity="center";
  {
    MaterialCardView,
    layout_width = "fill",
    StrokeWidth = 0,
    clickable = true,
    layout_marginLeft = "8dp",
    layout_marginRight = "8dp",
    id = "card",
    {
      LinearLayoutCompat,
      gravity = "center",
      layout_width = "fill",
      focusable=true;
      SettingsLayUtil.leftCoverLay;
      SettingsLayUtil.twoLineLay;
      infoLay;
      SettingsLayUtil.rightSwitchLay;
    },
  },
})
table.insert(itemsLay,{--设置项(头像,标题,简介)
  LinearLayoutCompat;
  layout_width="fill";
  gravity="center";
  {
    MaterialCardView,
    layout_width = "fill",
    StrokeWidth = 0,
    clickable = true,
    layout_marginLeft = "8dp",
    layout_marginRight = "8dp",
    id = "card",
    {
      LinearLayoutCompat,
      gravity = "center",
      layout_width = "fill",
      focusable=true;
      SettingsLayUtil.leftCoverIconLay;
      SettingsLayUtil.twoLineLay;
      infoLay;
      SettingsLayUtil.rightSwitchLay;
    },
  },
})