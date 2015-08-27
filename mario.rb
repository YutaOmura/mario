require "dxruby"

#マップデータ [1Block=32*32] Width17, height15
map = [[1, 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
       [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 7],
       [1, 0, 0, 1, 1, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 6],
       [1, 0, 0, 0, 0, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
       [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1],
       [1, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 1],
       [1, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 1, 1],
       [1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
       [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
       [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
       [1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1],
       [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1],
       [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1],
       [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1],
       [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1],
       [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1]]

#配置パーツ
block = []
block[0] = Image.new(32, 32, [50, 200, 255])  #空 背景
block[1] = Image.new(32, 32, [100, 50, 0])    #茶 ブロック
block[2] = Image.new(32, 32, [255, 255, 255]) #白 雲
block[3] = Image.new(32, 32, [0, 0, 0])       #黒 ゴール
block[4] = Image.load("kinoko.png") #アイテム画像
block[5] = Image.load("block.png")  #ブロック画像
block[6] = Image.load("goal2.png")  #ゴール画像
block[7] = Image.load("goal.png")   #ゴール画像
block[8] = Image.load("dokan.png")  #ドカン画像

#キャラ
character = Image.load("c_mario.png")

#初期値設定
x = 32
y = preview = 32
f = 1
item = 0
jump = false

#対応する配列を返す
def collision(x, y, array)
  return array[y/32][x/32]
end


#ループ開始
Window.loop do


  #Ｙ軸移動増分の設定
  y_move = (y - preview) + f


  #すりぬけ回避
  if y_move > 31
     y_move = 31
  end
  preview = y
  y += y_move
  f = 1 #重力設定


  #落下時 座標初期化
  if y >= 480
     x = 32
     y = preview = 0
     item = 0
     map[3][6] = 5 #ブロック再表示
     map[2][6] = 0 #アイテムを消去
  end


  #天井衝突判定
  if collision(x   , y, map) == 1 or 
     collision(x+31, y, map) == 1 then 
     y = y/32*32 + 32
  end
  #床衝突判定
  if collision(x   , y+31, map) == 1 or 
     collision(x+31, y+31, map) == 1 then
     y = y/32*32 
     jump = true  #地面に接地時ジャンプ許可
  else
     jump = false #不許可
  end


  #移動スピード
  if item == 1
    x += Input.x * 5
  else
  	x += Input.x * 2
  end


  #壁衝突判定（左側）
  if collision(x   , y   , map) == 1 or
     collision(x   , y+31, map) == 1 then
     x = x/32*32 + 32
  end
  #壁衝突判定（右側）
  if collision(x+31, y   , map) == 1 or 
     collision(x+31, y+31, map) == 1 then
     x = x/32*32
  end


  #アイテム衝突判定
  if collision(x   , y   , map) == 4 or 
     collision(x   , y+31, map) == 4 then
     x = x/32*32 + 32
     map[2][6] = 0
     item = 1
  end
  #ブロック衝突判定
  if collision(x   , y, map) == 5 or 
     collision(x+31, y, map) == 5 then 
     y = y/32*32 + 32
     map[2][6] = 4
     map[3][6] = 1
  end
  if collision(x   , y+31, map) == 5 or 
     collision(x+31, y+31, map) == 5 then
     y = y/32*32
     jump = true
  end


  #Escで終了
  if Input.key_push?(K_ESCAPE)
    break
  end

  #ジャンプ
  if Input.key_push?(K_SPACE) and jump
    f = -15
  end

  #マップの表示
  Window.draw_tile(0,0,map,block,0,0, 17, 15)

  #キャラの表示
  Window.draw(x, y, character)

end