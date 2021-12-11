#include "io.h"
#define putchar outb
float f(float x, float y, float z) {
    float a = x * x + 9.0f / 4.0f * y * y + z * z - 1;
    return a * a * a - x * x * z * z * z - 9.0f / 80.0f * y * y * z * z * z;
}

float h(float x, float z) {
    for (float y = 1.0f; y >= 0.0f; y -= 0.01f)
        if (f(x, y, z) <= 0.0f)
            return y;
    return 0.0f;
}

float mysqrt(float x) {
  if (x == 0) return 0;
  int i;
  double v = x / 2;
  for (i = 0; i < 50; ++i)
    v = (v + x / v)/2;
  
  return v;
}

int main() {
    // //60  7,32   z = 1.2 , x = -0.725
    //    //120
    //         //putchar('\n');
             float x = -0.725, z = 1.2;
    //         // float v = f(x, 0.0f, z);
            
               float y0 = h(x, z);
                //float y0 = 0.03;
                float ny = 0.01f;
                //outlln(ny * 100000);
                float nx = h(x + ny, z) - y0;
                //float nx = 0.02999;
                //outlln(nx * 100000);
                float nz = h(x, z + ny) - y0;
                //float nz = -0.03;
                //outlln((-nz) * 100000);
                float nd = 1.0f / mysqrt(nx * nx + ny * ny + nz * nz);
                //float nd = 22.9413;
                //outlln(nd * 100000);
                float d = (nx + ny - nz) * nd * 0.5f + 0.5f;
                //float d = 0.61469;
                //outlln(d * 100000);
                int index = (int)(d * 5.0f);
                //outlln(index * 100000);
                putchar(".:-=+*#%@"[index]);
        // float d = (nx + ny - nz) * nd * 0.5f + 0.5f;
        // int index = (int)(d * 5.0f);
        // outl(index * 100000);
        
       
    
}