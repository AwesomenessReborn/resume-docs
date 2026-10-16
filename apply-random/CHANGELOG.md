# BRELYON - Field Applications & Solutions Engineer

Base: [EE-CMPE resume](../tex/hari-resume-ee-cmpe.tex).
Tailored source: [BRELYON resume](tex/hari-resume-brelyon.tex).

## Changes and evidence

- **ST walking-speed deployment:** Replaced the first two EE-CMPE bullets with the Android/C++/JNI/NPU deployment bullet from the [SWE resume](../tex/hari-resume-swe.tex). Retained the EE-CMPE model's 129 KB size and 0.059 m/s MAE. Preserved 208 Hz, approximately 15 ms per 2.5 s window, and the exact claim "demoed at CES 2026." Removed the standalone preprocessing details (512-sample windows, Butterworth filtering, RobustScaler, C/Python tests); no retained metric was changed.
- **ST VR deployment:** Moved the existing third bullet to second, unchanged: 887K parameters, PyTorch -> ONNX -> QAIRT / Hexagon NPU on HTP v81, 0.056-degree agreement, and converter/tensor-layout debugging.
- **ST in-sensor deployment:** Retained unchanged as the third bullet, including ISPU/MLC, zero host-MCU compute, 104 Hz, 3.08 ms worst case, approximately 20 KB code, and 1.1 KB RAM.
- **Spartan Racing:** Moved physical HIL testing from third to first and board revisions/schematic feedback from fifth to second. Retained the latency/CAN, fault-handling, and firmware-migration bullets unchanged, now third through fifth. All numerical details remain intact.
- **MERIT UAV:** Moved ahead of MIPS. Front-loaded "integrated and flight-tested," supported by EE-CMPE's "validated in flight" and explicit MAVLink flight testing in the [ML resume](../tex/hari-resume-ml.tex). Retained 921600-baud UART, all four flight commands, GUIDED mode, concurrent 4 Hz GPS / 30 FPS CUDA YOLOv8n, GPS-lock gating, and the distinction that the vision pipeline was ground-tested.
- **MIPS SoC:** Moved below MERIT; kept its single bullet unchanged without expansion.
- **Invention disclosures:** Moved Motion-to-Photon Latency Compensation for XR/AR/VR Glasses above wellness glasses. Retained both titles, attribution, status, and dates without optics/display/graphics claims.
- **Skills:** Put embedded/hardware first, testing/debugging second, systems/deployment third, EDA/signal processing fourth, and ML deployment last. Imported Linux and JNI/NDK from SWE, Android from demonstrated ST work (also explicit in ML skills), and QNN/QAIRT from EE-CMPE deployment evidence and ML skills. Removed lower-priority Java, Kotlin, assembly, JNI Harness, agentic coding tools, SciPy, InfluxDB, Grafana, and Docker from the skills list.
- **Unchanged:** Contact information, education, job titles, employment dates, shared fonts, margins, and spacing. No ML training/loss-function bullets, Nemotron project, customer-facing claims, or unsupported sales/display/optics experience were added.

## Build

Run `make -C apply-random check` from the repository root. The build requires
exactly one page and no overfull boxes, and publishes the PDF to
`apply-random/build/pdf/hari-resume-brelyon.pdf`. Generated output is ignored
by Git; rebuild it from the tracked source as needed.

Validation: `make -C apply-random check` passed with one page and no overfull
boxes. Root `make check` passed for all three unchanged originals. macOS
PDFKit independently confirmed one page, extractable text, and 33 required
evidence/metric checks. Only the existing shared font-substitution and
`fancyhdr` footskip warnings remain; no layout settings were changed.
