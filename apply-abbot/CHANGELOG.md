# Abbot - On-Device ML Application

Base: [ML resume](../tex/hari-resume-ml.tex).
Tailored source: [Abbot resume](tex/hari-resume-abbot.tex).
Directory and standalone build mirror [apply-random](../apply-random/).

## Changes and evidence

- **ST mobile deployment:** Merged the ML walking-speed model evidence
  (103K parameters, 0.059 m/s MAE, INT8, Snapdragon NPU / Qualcomm QNN,
  CES 2026) with the [SWE resume](../tex/hari-resume-swe.tex)'s
  ring-buffered 208 Hz C++ IMU preprocessing, Android/JNI bridge, and
  approximately 15 ms per 2.5 s window.
- **ST validation:** Imported SWE's C/Python regression harness, keeping
  Python-reference numerical validation across TFLite, ONNX, and QNN
  explicit. This is exported-model regression testing, not a claim of
  production OTA or deployed-model versioning infrastructure.
- **ST second accelerator deployment:** Retained the 887K-parameter VR
  head-motion model's PyTorch -> ONNX -> QAIRT -> Hexagon NPU path and
  0.056-degree on-device parity; added SWE's converter/tensor-layout debugging.
- **ST constrained inference:** Kept in-sensor fall detection and wrist-tilt,
  zero host-MCU compute, 104 Hz sensor fusion, 3.08 ms worst case, and
  32% of budget. Added approximately 20 KB code / 1.1 KB RAM from the
  [EE-CMPE resume](../tex/hari-resume-ee-cmpe.tex).
- **ST training:** Moved the ML training-pipeline bullet last, retaining
  45+ GPU-hour runs, 2.5x throughput, bf16 / torch.compile, and per-horizon
  checkpoint saving. Omitted the standalone geodesic-loss/model-training
  improvement bullet to prioritize deployment and validation.
- **Formula SAE:** Put SWE's Python HIL validation first, followed by
  the ML STM32 latency optimization and state-of-charge estimation.
  Replaced the ML telemetry bullet with HIL evidence; did not add the
  lower-priority LTC6811/LTC6813 firmware migration.
- **Patents:** Kept both ML entries, with wellness/health monitoring first.
- **Projects:** Put MERIT ahead of Nemotron-H, below both experience entries.
  Used EE-CMPE's explicit distinction between flight-tested MAVLink control
  and ground-tested vision. Compressed Nemotron-H to one fine-tuning and
  evaluation bullet without suggesting mobile or wearable deployment.
- **Skills:** Led with Python/C++, PyTorch/TFLite/ONNX/QNN/QAIRT, and Android
  NDK/JNI. Kept IMU, sensor fusion, on-device ML, real-time inference, and
  validation prominent; removed lower-priority infrastructure and tooling.
- **Unchanged:** Contact information, education, employment titles/dates,
  patent attribution/status/dates, shared fonts, margins, and spacing.
  No Theta Tau/backend web content, cloud/device split architecture,
  production OTA, regulated medical-device, clinical, or inflated tenure
  claims were added.

## Build

Run `make -C apply-abbot check` from the repository root. The strict build
requires exactly one page and no overfull boxes, and publishes the PDF to
`apply-abbot/build/pdf/hari-resume-abbot.pdf`. Generated output is ignored
by Git; edit the tailored source and rerun Make for further tailoring.
The base ML resume and other applications are built independently.

Validation: `make -C apply-abbot check` passed with exactly one page and no
overfull boxes. Root `make check` passed for all three unchanged base
resumes. Only the existing shared font-substitution and `fancyhdr`
footskip warnings remain; no layout settings were changed.
