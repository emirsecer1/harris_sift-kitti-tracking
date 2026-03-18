# KITTI Visual Odometry — Harris Corner Detection & Feature Tracking

> **A MATLAB-based visual odometry pipeline implementing Harris corner detection, NCC-based template matching, and SIFT/SURF descriptor tracking on the [KITTI](http://www.cvlibs.net/datasets/kitti/) benchmark dataset.**

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Pipeline Architecture](#pipeline-architecture)
- [Algorithms](#algorithms)
  - [Harris Corner Detection](#harris-corner-detection)
  - [NCC Template Matching](#ncc-template-matching)
  - [SIFT/SURF Descriptor Tracking](#siftsurfs-descriptor-tracking)
- [Repository Structure](#repository-structure)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Quick Start (Synthetic Demo)](#quick-start-synthetic-demo)
  - [Full Pipeline (KITTI Dataset)](#full-pipeline-kitti-dataset)
- [Configuration](#configuration)
- [Output](#output)
- [Performance Metrics](#performance-metrics)
- [Sample Results](#sample-results)
- [References](#references)
- [License](#license)

---

## Overview

This project implements a complete **visual odometry** pipeline for autonomous driving research. It detects stable interest points in video frames using the **Harris corner detector** and tracks them across consecutive frames via two complementary strategies:

1. **Normalized Cross-Correlation (NCC)** patch-based template matching
2. **SIFT/SURF** descriptor matching (requires Computer Vision Toolbox)

The system is evaluated on the [KITTI Raw Dataset](http://www.cvlibs.net/datasets/kitti/raw_data.php), a widely used benchmark for autonomous vehicle perception (Geiger et al., 2013).

---

## Features

| Category | Details |
|---|---|
| **Corner Detection** | Harris corner detector with configurable threshold, Gaussian smoothing, and non-maximum suppression |
| **Dual Tracking** | NCC template matching + SIFT/SURF descriptor matching |
| **Synthetic Testing** | Built-in checkerboard test images allow running without the KITTI dataset |
| **Dynamic Reinjection** | Automatically detects new corners when the tracked count drops below 50 % |
| **Visualization Suite** | 7 visualization functions — trajectories, density heatmaps, 3D trajectory plots, performance dashboards, and more |
| **Automated Reporting** | Generates timestamped text reports and multi-panel statistical plots |
| **Parameter Tuning** | Includes a parameter comparison tool to benchmark different configurations |

---

## Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                  INPUT: KITTI Image Sequence                 │
└──────────────────────────────┬───────────────────────────────┘
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  1. Harris Corner Detection  (harris_detector.m)             │
│     • Sobel gradients  Ix, Iy                                │
│     • Gaussian-weighted structure tensor  M                  │
│     • Response  R = det(M) − k · trace(M)²                  │
│     • Non-maximum suppression → top-N corners                │
└──────────────────────────────┬───────────────────────────────┘
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  2. Feature Tracking  (feature_tracker.m / sift_tracker.m)   │
│     • NCC template matching  (15×15 patch, ±20 px search)    │
│     • SIFT/SURF descriptor matching  (optional fallback)     │
│     • Displacement computation:  d = √(Δx² + Δy²)           │
│     • Corner reinjection when count < 50 %                   │
└──────────────────────────────┬───────────────────────────────┘
                               ▼
┌──────────────────────────────────────────────────────────────┐
│  3. Analysis & Visualization                                 │
│     • Tracking statistics & success rate                     │
│     • Motion/displacement analysis                           │
│     • Multi-panel dashboards  (analysis_report.m)            │
│     • Video output with overlaid motion vectors              │
└──────────────────────────────────────────────────────────────┘
```

---

## Algorithms

### Harris Corner Detection

Implementation of the method originally proposed by Harris & Stephens (1988).

Given a grayscale image *I*, the algorithm computes:

1. **Image gradients** using Sobel operators:  *I_x*, *I_y*
2. **Structure tensor** components smoothed by a Gaussian (*σ* = 1.5):  *S_x²*, *S_y²*, *S_xy*
3. **Corner response**:  *R = det(M) − k · trace(M)²* , where *k* = 0.04
4. **Non-maximum suppression** via morphological dilation, followed by thresholding

### NCC Template Matching

For each tracked corner in the previous frame, a *15 × 15* pixel patch is extracted and slid over a *±20 px* search window in the current frame. The match quality is measured by:

```
NCC = [Σ (T − μ_T)(C − μ_C)] / [‖T − μ_T‖ · ‖C − μ_C‖]
```

A match is accepted when NCC > 0.7 (configurable).

### SIFT/SURF Descriptor Tracking

When the Computer Vision Toolbox is available, the tracker extracts **SURF** descriptors around each Harris corner and matches them using Lowe's ratio test. If SURF is not available, it falls back to **BRISK** descriptors. This approach provides robustness to rotation, scale changes, and illumination variation compared to pure template matching.

---

## Repository Structure

```
harris_sift-kitti-tracking/
│
├── harris_main.m                 # Main pipeline script (loads KITTI, runs detection & tracking)
├── harris_detector.m             # Harris corner detection (Sobel + Gaussian + NMS)
├── feature_tracker.m             # NCC patch-based template matching tracker
├── sift_tracker.m                # SIFT/SURF descriptor-based tracker (optional)
├── analysis_report.m             # Statistical analysis & text/graphic reporting
├── visualization_tools.m         # 7 visualization functions (trajectories, heatmaps, dashboards)
├── test_demo.m                   # Synthetic data demo & KITTI integration test
├── tracking_results_small.mp4    # Sample output video
├── Sonuclar.pdf                  # Results report (PDF)
├── Harris Köşe Algılama ve
│   Özellik İzleme ile Visual
│   Odometry.docx                 # Detailed project documentation (Turkish)
└── README.md                     # This file
```

---

## Requirements

### Software

| Dependency | Version | Required |
|---|---|---|
| **MATLAB** | R2019b or later | ✅ Yes |
| **Image Processing Toolbox** | — | ✅ Yes |
| **Computer Vision Toolbox** | — | ⬜ Optional (enables SIFT/SURF tracking) |

### Dataset

| Item | Details |
|---|---|
| **Name** | KITTI Raw Dataset |
| **URL** | <http://www.cvlibs.net/datasets/kitti/raw_data.php> |
| **Resolution** | 1241 × 376 px (grayscale) |
| **Minimum frames** | 200 |
| **Sequences** | Any sequence (e.g., `00`) |

> **Note:** The synthetic demo (`test_demo.m`) can run without the KITTI dataset.

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/emirsecer1/harris_sift-kitti-tracking.git
cd harris_sift-kitti-tracking
```

### 2. Download the KITTI dataset

Download grayscale image sequences from the [KITTI website](http://www.cvlibs.net/datasets/kitti/raw_data.php) and organize them as follows:

```
KITTI/
└── sequences/
    └── 00/
        ├── image_0/
        │   ├── 000000.png
        │   ├── 000001.png
        │   └── ...
        └── image_1/
```

### 3. Configure the data path

Open `harris_main.m` and set `dataPath` to point to your local KITTI directory:

```matlab
dataPath = 'C:/KITTI/sequences/00/image_0/';   % <-- update this
```

### 4. Add files to the MATLAB path

In the MATLAB Command Window, navigate to the project directory or run:

```matlab
addpath('/path/to/harris_sift-kitti-tracking');
```

---

## Usage

### Quick Start (Synthetic Demo)

Run the synthetic test without the KITTI dataset:

```matlab
test_demo
```

This generates a checkerboard image with synthetic corners, runs Harris detection, simulates a known translation, and validates tracking accuracy.

### Full Pipeline (KITTI Dataset)

```matlab
harris_main
```

Or select mode 2 inside the demo script:

```matlab
testMode = 2;
test_demo
```

---

## Configuration

All parameters are defined at the top of `harris_main.m`:

### Harris Detection Parameters

| Parameter | Default | Description |
|---|---|---|
| `k` | 0.04 | Harris sensitivity constant (typical range 0.04 – 0.06) |
| `threshold` | 0.01 | Corner response threshold |
| `windowSize` | 3 | Gradient computation window |
| `sigma` | 1.5 | Gaussian smoothing standard deviation |
| `maxCorners` | 500 | Maximum number of corners to retain |

### Tracking Parameters

| Parameter | Default | Description |
|---|---|---|
| `patchSize` | 15 | Template patch size (pixels) |
| `searchRadius` | 20 | Search window radius (pixels) |
| `similarityThreshold` | 0.7 | Minimum NCC score to accept a match |
| `useSIFT` | `true` | Enable SIFT/SURF descriptor matching |

### Visualization Parameters

| Parameter | Default | Description |
|---|---|---|
| `saveVideo` | `true` | Save tracking result as video |
| `videoName` | `'tracking_results.avi'` | Output video filename |

---

## Output

| Output | Format | Description |
|---|---|---|
| **Tracking video** | `.avi` | Annotated frames with corners and motion vectors |
| **Text report** | `.txt` | Timestamped statistics (success rate, displacement, etc.) |
| **Statistical plots** | MATLAB figures | Multi-panel dashboards with distributions and time series |
| **Console summary** | Terminal | Real-time per-frame statistics |

---

## Performance Metrics

The analysis module (`analysis_report.m`) computes:

| Metric | Definition |
|---|---|
| **Tracked features** | Number of successfully matched corners per frame |
| **Lost features** | Corners that could not be re-detected |
| **Success rate** | `tracked / (tracked + lost) × 100 %` |
| **Mean displacement** | Average pixel-level motion magnitude |
| **Tracking stability** | Moving standard deviation of feature count (window = 10) |

Performance ratings: **Excellent** (> 85 %), **Good** (> 70 %), **Fair** (> 50 %), **Poor** (≤ 50 %).

---

## Sample Results

A sample tracking video is included in the repository:

📹 **[tracking_results_small.mp4](tracking_results_small.mp4)** — shows detected Harris corners (green markers), motion vectors (red quiver arrows), and lost features (red × markers) on a KITTI sequence.

---

## References

1. C. Harris and M. Stephens, "A Combined Corner and Edge Detector," *Proceedings of the 4th Alvey Vision Conference*, pp. 147–151, 1988.
2. D. G. Lowe, "Distinctive Image Features from Scale-Invariant Keypoints," *International Journal of Computer Vision*, vol. 60, no. 2, pp. 91–110, 2004.
3. H. Bay, T. Tuytelaars, and L. Van Gool, "SURF: Speeded-Up Robust Features," *European Conference on Computer Vision (ECCV)*, pp. 404–417, 2006.
4. A. Geiger, P. Lenz, C. Stiller, and R. Urtasun, "Vision meets Robotics: The KITTI Dataset," *International Journal of Robotics Research*, vol. 32, no. 11, pp. 1231–1237, 2013.

---

## License

This project is provided for **academic and educational purposes**. If you use this work, please cite the references above and provide attribution to this repository.

