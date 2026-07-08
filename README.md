# I2C & SPI RTL Design

Verilog/SystemVerilog를 사용하여 I2C 및 SPI 프로토콜을 RTL로 설계하고,  
Testbench, UVM 및 FPGA를 활용하여 RTL 동작을 검증한 프로젝트입니다.

---

## Contents

- [I2C RTL Design](#i2c-rtl-design)
- [SPI RTL Design](#spi-rtl-design)
- [What I Learned](#what-i-learned)

---
## I2C RTL Design

### Top Architecture

![I2C Top Architecture](images/i2c_top.png)

(작성 예정)

---

### I2C Protocol

![I2C Top Architecture](images/I2C_Protocol.png)

#### I2C Master FSM

<p align="center">
  <img src="images/I2C_Master_FSM.png" width="700">
</p>

#### SCL/SDA 설계

##### Step 생성

![I2C Top Architecture](images/Quater_tick.png)

##### Start/Stop Condition 설계

![I2C Top Architecture](images/I2C_Start_Stop.png)

######  SCL/SDA 설계

![I2C Top Architecture](images/I2C_Data.png)


## SPI RTL Design

(작성 예정)

---

## What I Learned

(작성 예정)
