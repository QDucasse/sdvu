# Synthesis notes related to SDVU
> Vivado 2018.2 - Default settings
>
> Synthesis results are given for SDVU core + both program/config memories!

## 1 SDVU core

|        Site Type        | Used | Fixed | Available | Util% |
|-------------------------|------|--------|-----------|-------|
| Slice LUTs*             | 3597 |     0 |     53200 |  6.76 |
|   LUT as Logic          | 3597 |     0 |     53200 |  6.76 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         | 2330 |     0 |    106400 |  2.19 |
|   Register as Flip Flop | 2074 |     0 |    106400 |  1.95 |
|   Register as Latch     |  256 |     0 |    106400 |  0.24 |
| F7 Muxes                |  194 |     0 |     26600 |  0.73 |
| F8 Muxes                |   97 |     0 |     13300 |  0.73 |

## 2 SDVUs

| Site Type             | Used | Fixed | Available | Util% |
| --------------------- | ---- | ----- | --------- | ----- |
| Slice LUTs*           | 7348 | 0     | 53200     | 13.81 |
| LUT as Logic          | 7348 | 0     | 53200     | 13.81 |
| LUT as Memory         | 0    | 0     | 17400     | 0.00  |
| Slice Registers       | 4662 | 0     | 106400    | 4.38  |
| Register as Flip Flop | 4150 | 0     | 106400    | 3.90  |
| Register as Latch     | 512  | 0     | 106400    | 0.48  |
| F7 Muxes              | 384  | 0     | 26600     | 1.44  |
| F8 Muxes              | 192  | 0     | 13300     | 1.44  |

## 3 SDVUs

|        Site Type        |  Used | Fixed | Available | Util% |
|-------------------------|-------|-------|-----------|-------|
| Slice LUTs*             | 11007 |     0 |     53200 | 20.69 |
|   LUT as Logic          | 11007 |     0 |     53200 | 20.69 |
|   LUT as Memory         |     0 |     0 |     17400 |  0.00 |
| Slice Registers         |  6992 |     0 |    106400 |  6.57 |
|   Register as Flip Flop |  6224 |     0 |    106400 |  5.85 |
|   Register as Latch     |   768 |     0 |    106400 |  0.72 |
| F7 Muxes                |   576 |     0 |     26600 |  2.17 |
| F8 Muxes                |   288 |     0 |     13300 |  2.17 |

## 5 SDVUs

| Site Type             | Used  | Fixed | Available | Util% |
| --------------------- | ----- | ----- | --------- | ----- |
| Slice LUTs*           | 18325 | 0     | 53200     | 34.45 |
| LUT as Logic          | 18325 | 0     | 53200     | 34.45 |
| LUT as Memory         | 0     | 0     | 17400     | 0.00  |
| Slice Registers       | 11652 | 0     | 106400    | 10.95 |
| Register as Flip Flop | 10372 | 0     | 106400    | 9.75  |
| Register as Latch     | 1280  | 0     | 106400    | 1.20  |
| F7 Muxes              | 960   | 0     | 26600     | 3.61  |
| F8 Muxes              | 480   | 0     | 13300     | 3.61  |

## 10 SDVUs

| Site Type             | Used  | Fixed | Available | Util% |
| --------------------- | ----- | ----- | --------- | ----- |
| Slice LUTs*           | 36625 | 0     | 53200     | 68.84 |
| LUT as Logic          | 36625 | 0     | 53200     | 68.84 |
| LUT as Memory         | 0     | 0     | 17400     | 0.00  |
| Slice Registers       | 23306 | 0     | 106400    | 21.90 |
| Register as Flip Flop | 20746 | 0     | 106400    | 19.50 |
| Register as Latch     | 2560  | 0     | 106400    | 2.41  |
| F7 Muxes              | 1920  | 0     | 26600     | 7.22  |
| F8 Muxes              | 960   | 0     | 13300     | 7.22  |

## 14 SDVUs

| Site Type             | Used  | Fixed | Available | Util% |
| --------------------- | ----- | ----- | --------- | ----- |
| Slice LUTs*           | 51264 | 0     | 53200     | 96.36 |
| LUT as Logic          | 51264 | 0     | 53200     | 96.36 |
| LUT as Memory         | 0     | 0     | 17400     | 0.00  |
| Slice Registers       | 32628 | 0     | 106400    | 30.67 |
| Register as Flip Flop | 29044 | 0     | 106400    | 27.30 |
| Register as Latch     | 3584  | 0     | 106400    | 3.37  |
| F7 Muxes              | 2688  | 0     | 26600     | 10.11 |
| F8 Muxes              | 1344  | 0     | 13300     | 10.11 |