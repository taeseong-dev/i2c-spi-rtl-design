# I2C & SPI RTL Design

Verilog/SystemVerilog를 사용하여 I2C 및 SPI 프로토콜을 RTL로 설계하고,<br>
Testbench, UVM 및 FPGA를 활용하여 RTL 동작을 검증한 프로젝트입니다.

---

## Contents

- [I2C RTL Design](#i2c-rtl-design)
- [SPI RTL Design](#spi-rtl-design)
- [What I Learned](#what-i-learned)

---

## I2C RTL Design

### Top Architecture

<img src="images/i2c_top.png" width="650">

- I2C Master/Slave Top-Level 인터페이스 구성
- SCL/SDA 기반 I2C 통신 구조

---

### I2C Address and Data Frames

<img src="images/i2c_frame_format.png" width="800">

- Start → Address Frame → Data Frame → Stop
- Address/RW 전송 후 Data 송수신

---

## I2C Master

#### I2C Master FSM

<img src="images/I2C_Master_FSM.png" width="400">

- **IDLE** : 초기 상태
- **START** : Start Condition 생성
- **WAIT_CMD** : Read/Write 및 Stop/Restart 명령 대기
- **DATA** : Read/Write 동작
- **DATA_ACK** : ACK 송수신
- **STOP** : Stop Condition 생성

---

#### SCL / SDA 설계

##### Step 생성

<img src="images/Quater_tick.png" width="600">

- Clock Divider를 이용한 Quarter Tick 생성
- Step Counter를 이용한 4-Step 생성

##### Start / Stop Condition 설계

<img src="images/I2C_Start_Stop.png" width="600">

- 4-Step Timing을 이용한 Start/Stop Condition 생성

##### Data Transfer

<img src="images/I2C_Data.png" width="600">

- Step별 SDA/SCL 출력 값 정의
- 4-Step Timing에 따른 출력 제어

##### Write Sequence

<img src="images/i2c_master_write.png" width="600">

##### Read Sequence

<img src="images/i2c_master_read.png" width="600">

##### Open-Drain SDA

<img src="images/i2c_pull_up.png" width="600">

• SDA는 Open-Drain 방식으로 동작  
• High는 High-Z, Low는 0을 출력하여 Pull-up으로 High 유지
• Pull-up 저항을 통해 Bus의 High 상태 유지

---

## I2C Slave

### Slave FSM

<img src="images/i2c_slave_fsm.png" width="400">

- **IDLE** : Start Condition 대기
- **ADDR** : Slave Address 수신 및 비교
- **ADDR_RW** : Read/Write 모드 결정
- **ADDR_ACK** : Address Match 시 ACK 출력
- **DATA** : Read/Write 데이터 송수신
- **DATA_ACK** : ACK/NACK에 따른 다음 동작 결정

### SCL Edge Timing

<img src="images/i2c_slave_edge.png" width="400">

- Rising Edge에서 SDA 신호 Sampling
- Falling Edge에서 ACK 및 Read Data 출력

## I2C Verification

### Simulation Waveform

- Sequence : 2byte write -> 1byte read

<img src="images/i2c_sim_write.png" width = "800">

- Master -> Slave 2Byte Write

<img src="images/i2c_sim_read.png" width = "800">

- Slave -> Master 1byte Read

## SPI RTL Design

(작성 예정)

---

## What I Learned

(작성 예정)
