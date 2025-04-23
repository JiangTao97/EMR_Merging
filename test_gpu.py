# test_gpu.py

import torch

def test_gpu():
    if torch.cuda.is_available():
        device_name = torch.cuda.get_device_name(0)
        device_count = torch.cuda.device_count()
        print(f"✅ GPU 可用，共 {device_count} 块 GPU")
        print(f"🖥️ 当前使用的 GPU: {device_name}")
        print("🚀 测试张量计算中...")

        # 测试张量运算是否正常
        x = torch.randn(10000, 10000).cuda()
        y = torch.matmul(x, x)
        print("🎉 张量计算成功，结果形状：", y.shape)
    else:
        print("❌ 当前环境中 GPU 不可用")

if __name__ == "__main__":
    test_gpu()
    
    import torch
    print(torch.version.cuda)
    print(torch.backends.cudnn.version())
    print(torch.cuda.get_device_name(0))