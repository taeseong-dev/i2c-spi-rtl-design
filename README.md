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

<img src="images/i2c_sim_write.png" width = "700">

- Sequence : START -> ADDRESSS/RW(0x24) -> DATA(0xab) -> DATA(0xcd) -> STOP
- Multi-byte Data Write 수행
- Master TX Data → Slave RX Data 확인

<img src="images/i2c_sim_read.png" width = "700">

- Sequence : START → ADDRESS → READ DATA(0xCD) → STOP
- Data Read 수행
- Write Data와 Read Data 일치 확인

### UVM Verification

#### UVM Architecture

<img src="images/i2c_uvm.png" width = "500">

- Sequence에서 생성한 데이터를 Driver를 통해 DUT에 전달
- Monitor를 통해 DUT 동작 확인
- Scoreboard 비교 및 Coverage를 통한 기능 검증

## Verification Items

> Sequence에서 생성한 Transaction과 Monitor가 SCL/SDA 신호를 통해 생성한 Transaction을 비교하여
> I2C 프로토콜 동작을 검증하였습니다.

### Data Verification

| 검증 항목 | 검증 내용 |
|-----------|-----------|
| Address / RW | Sequence ↔ Monitor Address/RW 비교 |
| Write Data | Sequence ↔ Monitor Write Data 비교 |
| Slave RX Data | Sequence Write Data ↔ Slave RX Data 비교 |
| Read Data | 마지막 Write Data ↔ Monitor Read Data 비교 |

### ACK Verification

| 검증 항목 | 검증 내용 |
|-----------|-----------|
| Address ACK / NACK | Address 전송 후 ACK/NACK 응답 확인 |
| Data ACK | Data 전송 후 ACK 응답 확인 |

## Test Scenarios

| Scenario | Description |
|----------|-------------|
| Write | Single-byte / Multi-byte Write |
| Read | Single-byte Read |
| Write & Read | Write한 Data의 Read 동작 검증 |
| Random | Write / Read Sequence를 랜덤하게 반복 수행 |

## Functional Coverage

> Random Sequence를 수행하여 Address, Read/Write Operation, Data 및 Multi-byte Transfer Length에 대한 Functional Coverage를 수집하였습니다.

### Coverage Items

| Coverage Item | Description |
|---------------|-------------|
| Address | Valid Address (7'h12) / Invalid Address |
| RW | Read / Write Operation |
| Data | Boundary Value, Pattern, Bit Pattern 및 Data Range |
| Num Data | Multi-byte Transfer Length (1~8 Byte) |

### Data Coverage

| Category | Coverage Target |
|----------|-----------------|
| Boundary Value | 0x00, 0xFF |
| Pattern | 0x55, 0xAA |
| Bit Pattern | 0x01, 0x80 |
| Data Range | Low / Mid / High |

### Coverage Result

| Coverage Item | Result |
|---------------|:------:|
| Address | 100% |
| RW | 100% |
| Data | 100% |
| Num Data | 100% |

<img src="images/i2c_cov.png" width="200">

## Verification Result

> Random Sequence를 1000회 수행하여 Transaction 비교 및 Scoreboard 검증을 진행하였습니다.

### Transaction Summary

| Transaction | Count |
|-------------|------:|
| Write | 429 |
| Read | 468 |
| Address NACK | 103 |
| **Total** | **1000** |

### Verification Result

| Verification Item | Result |
|-------------------|:------:|
| Address / RW | PASS |
| Address ACK | PASS |
| Address NACK | PASS |
| Write Data | PASS |
| Read Data | PASS |

<img src="images/i2c_scb.png" width="350">

## SPI RTL Design

(작성 예정)

---

## What I Learned

(작성 예정)
