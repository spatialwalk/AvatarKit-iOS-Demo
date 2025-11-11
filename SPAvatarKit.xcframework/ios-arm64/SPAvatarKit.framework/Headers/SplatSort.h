#ifndef SplatSort_h
#define SplatSort_h

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// 高斯点位置结构
typedef struct {
    float x, y, z;
} SplatPosition;

// 排序函数
void sortSplatIndexes(const SplatPosition* positions,
                     uint32_t vertexCount,
                     float cameraForwardX,
                     float cameraForwardY, 
                     float cameraForwardZ,
                     float cameraForwardW,
                     uint32_t* depthIndex);

#ifdef __cplusplus
}
#endif

#endif /* SplatSort_h */ 