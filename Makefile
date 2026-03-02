# 変数定義
ASM = as
ASMFLAGS = 
LD = ld
LDFLAGS = 
TARGET = attendance
SRC = attendance.s
OBJ = attendance.o

# デフォルトターゲット
all: $(TARGET)

# アセンブルとリンク
$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJ)

$(OBJ): $(SRC)
	$(ASM) $(ASMFLAGS) $(SRC) -o $(OBJ)

# 実行
run: $(TARGET)
	./$(TARGET)

# クリーンアップ
clean:
	rm -f $(OBJ) $(TARGET)

# データファイルもクリーンアップ
clean-all: clean
	rm -f attendance.dat

# デバッグビルド
debug: ASMFLAGS += -g -F dwarf
debug: $(TARGET)

.PHONY: all run clean clean-all debug
