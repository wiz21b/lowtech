from utils import show_hgr, cut_image

# with open("data/a.asm", "r") as fin:
#     data = []
#     for line in fin.readlines()[1:]:
#         l = [int(x) for x in line.replace(".byte", "").strip().split(",")]
#         data.extend(l)

#     show_hgr(data)
#     with open("out2.hgr", "wb") as fout:
#         fout.write(bytes(data))


with open("out.hgr", "rb") as fout:
    data = fout.read()
    show_hgr(data)

Y_START, Y_END = 162, 180
X = [10, 24, 52, 80, 108, 136, 164, 178, 198+7, 198+5*7]

for i in range(len(X) - 1):
    x1, x2 = (X[i] // 7), (X[i+1] // 7) - 1
    print(f"{x1} - {x2} => {x2-x1+1}")
    cut_image("out.hgr", f"build/imphobia{i}.blk",
              x1, Y_START, x2, Y_END)
