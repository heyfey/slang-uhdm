// § ovrMemberReadLocatesLeftover232

package cva6_config_pkg;

  localparam CVA6ConfigXlen = 32;

  localparam CVA6ConfigFpuEn = 0;
  localparam CVA6ConfigF16En = 0;
  localparam CVA6ConfigF16AltEn = 0;
  localparam CVA6ConfigF8En = 0;
  localparam CVA6ConfigFVecEn = 0;

  localparam CVA6ConfigCvxifEn = 0;
  localparam CVA6ConfigCExtEn = 1;
  localparam CVA6ConfigZcbExtEn = 0;
  localparam CVA6ConfigZcmpExtEn = 0;
  localparam CVA6ConfigAExtEn = 1;
  localparam CVA6ConfigBExtEn = 0;
  localparam CVA6ConfigVExtEn = 0;
  localparam CVA6ConfigZiCondExtEn = 0;

  localparam CVA6ConfigAxiIdWidth = 4;
  localparam CVA6ConfigAxiAddrWidth = 64;
  localparam CVA6ConfigAxiDataWidth = 64;
  localparam CVA6ConfigFetchUserEn = 0;
  localparam CVA6ConfigFetchUserWidth = CVA6ConfigXlen;
  localparam CVA6ConfigDataUserEn = 0;
  localparam CVA6ConfigDataUserWidth = CVA6ConfigXlen;

  localparam CVA6ConfigIcacheByteSize = 16384;
  localparam CVA6ConfigIcacheSetAssoc = 4;
  localparam CVA6ConfigIcacheLineWidth = 128;
  localparam CVA6ConfigDcacheByteSize = 32768;
  localparam CVA6ConfigDcacheSetAssoc = 8;
  localparam CVA6ConfigDcacheLineWidth = 128;

  localparam CVA6ConfigDcacheIdWidth = 1;
  localparam CVA6ConfigMemTidWidth = 2;

  localparam CVA6ConfigWtDcacheWbufDepth = 8;

  localparam CVA6ConfigNrCommitPorts = 2;
  localparam CVA6ConfigNrScoreboardEntries = 8;
  localparam CVA6ConfigNrLoadBufEntries = 2;

  localparam CVA6ConfigFPGAEn = 0;

  localparam CVA6ConfigNrLoadPipeRegs = 1;
  localparam CVA6ConfigNrStorePipeRegs = 0;

  localparam CVA6ConfigInstrTlbEntries = 2;
  localparam CVA6ConfigDataTlbEntries = 2;

  localparam CVA6ConfigRASDepth = 2;
  localparam CVA6ConfigBTBEntries = 32;
  localparam CVA6ConfigBHTEntries = 128;

  localparam CVA6ConfigTvalEn = 1;

  localparam CVA6ConfigNrPMPEntries = 8;

  localparam CVA6ConfigPerfCounterEn = 1;

  localparam config_pkg::cache_type_t CVA6ConfigDcacheType = config_pkg::WT;

  localparam CVA6ConfigMmuPresent = 1;

  localparam CVA6ConfigRvfiTrace = 1;

  localparam config_pkg::cva6_user_cfg_t cva6_cfg = '{
      XLEN: unsigned'(CVA6ConfigXlen),
      FPGA_EN: bit'(CVA6ConfigFPGAEn),
      NrCommitPorts: unsigned'(CVA6ConfigNrCommitPorts),
      AxiAddrWidth: unsigned'(CVA6ConfigAxiAddrWidth),
      AxiDataWidth: unsigned'(CVA6ConfigAxiDataWidth),
      AxiIdWidth: unsigned'(CVA6ConfigAxiIdWidth),
      AxiUserWidth: unsigned'(CVA6ConfigDataUserWidth),
      MemTidWidth: unsigned'(CVA6ConfigMemTidWidth),
      NrLoadBufEntries: unsigned'(CVA6ConfigNrLoadBufEntries),
      FpuEn: bit'(CVA6ConfigFpuEn),
      XF16: bit'(CVA6ConfigF16En),
      XF16ALT: bit'(CVA6ConfigF16AltEn),
      XF8: bit'(CVA6ConfigF8En),
      RVA: bit'(CVA6ConfigAExtEn),
      RVB: bit'(CVA6ConfigBExtEn),
      RVV: bit'(CVA6ConfigVExtEn),
      RVC: bit'(CVA6ConfigCExtEn),
      RVZCB: bit'(CVA6ConfigZcbExtEn),
      RVZCMP: bit'(CVA6ConfigZcmpExtEn),
      XFVec: bit'(CVA6ConfigFVecEn),
      CvxifEn: bit'(CVA6ConfigCvxifEn),
      ZiCondExtEn: bit'(CVA6ConfigZiCondExtEn),
      NrScoreboardEntries: unsigned'(CVA6ConfigNrScoreboardEntries),
      RVS: bit'(1),
      RVU: bit'(1),
      HaltAddress: 64'h800,
      ExceptionAddress: 64'h808,
      RASDepth: unsigned'(CVA6ConfigRASDepth),
      BTBEntries: unsigned'(CVA6ConfigBTBEntries),
      BHTEntries: unsigned'(CVA6ConfigBHTEntries),
      DmBaseAddress: 64'h0,
      TvalEn: unsigned'(CVA6ConfigTvalEn),
      NrPMPEntries: unsigned'(CVA6ConfigNrPMPEntries),
      PMPCfgRstVal: {16{64'h0}},
      PMPAddrRstVal: {16{64'h0}},
      PMPEntryReadOnly: 16'd0,
      NOCType: config_pkg::NOC_TYPE_AXI4_ATOP,
      NrNonIdempotentRules: unsigned'(2),
      NonIdempotentAddrBase: 1024'({64'b0, 64'b0}),
      NonIdempotentLength: 1024'({64'b0, 64'b0}),
      NrExecuteRegionRules: unsigned'(3),
      //                      DRAM,          Boot ROM,   Debug Module
      ExecuteRegionAddrBase:
      1024'(
      {64'h8000_0000, 64'h1_0000, 64'h0}
      ),
      ExecuteRegionLength: 1024'({64'h40000000, 64'h10000, 64'h1000}),
      NrCachedRegionRules: unsigned'(1),
      CachedRegionAddrBase: 1024'({64'h8000_0000}),
      CachedRegionLength: 1024'({64'h40000000}),
      MaxOutstandingStores: unsigned'(7),
      DebugEn: bit'(1),
      AxiBurstWriteEn: bit'(0),
      IcacheByteSize: unsigned'(CVA6ConfigIcacheByteSize),
      IcacheSetAssoc: unsigned'(CVA6ConfigIcacheSetAssoc),
      IcacheLineWidth: unsigned'(CVA6ConfigIcacheLineWidth),
      DcacheByteSize: unsigned'(CVA6ConfigDcacheByteSize),
      DcacheSetAssoc: unsigned'(CVA6ConfigDcacheSetAssoc),
      DcacheLineWidth: unsigned'(CVA6ConfigDcacheLineWidth),
      DataUserEn: unsigned'(CVA6ConfigDataUserEn),
      FetchUserWidth: unsigned'(CVA6ConfigFetchUserWidth),
      FetchUserEn: unsigned'(CVA6ConfigFetchUserEn)
  };
endpackage




package config_pkg;

  // ---------------
  // Global Config
  // ---------------
  localparam int unsigned ILEN = 32;
  localparam int unsigned NRET = 1;

  /// The NoC type is a top-level parameter, hence we need a bit more
  /// information on what protocol those type parameters are supporting.
  /// Currently two values are supported"
  typedef enum {
    /// The "classic" AXI4 protocol.
    NOC_TYPE_AXI4_ATOP,
    /// In the OpenPiton setting the WT cache is connected to the L15.
    NOC_TYPE_L15_BIG_ENDIAN,
    NOC_TYPE_L15_LITTLE_ENDIAN
  } noc_type_e;

  /// Cache type parameter
  typedef enum logic [1:0] {
    WB = 0,
    WT = 1,
    HPDCACHE = 2
  } cache_type_t;

  /// Data and Address length
  typedef enum logic [3:0] {
    ModeOff  = 0,
    ModeSv32 = 1,
    ModeSv39 = 8,
    ModeSv48 = 9,
    ModeSv57 = 10,
    ModeSv64 = 11
  } vm_mode_t;

  localparam NrMaxRules = 16;

  typedef struct packed {
    // General Purpose Register Size (in bits)
    int unsigned                 XLEN;
    // Is FPGA optimization of CV32A6
    bit                          FPGA_EN;
    // Number of commit ports
    int unsigned                 NrCommitPorts;
    // AXI address width
    int unsigned                 AxiAddrWidth;
    // AXI data width
    int unsigned                 AxiDataWidth;
    // AXI ID width
    int unsigned                 AxiIdWidth;
    // AXI User width
    int unsigned                 AxiUserWidth;
    // TODO
    int unsigned                 MemTidWidth;
    // Load buffer entry buffer
    int unsigned                 NrLoadBufEntries;
    // Floating Point
    bit                          FpuEn;
    // Non standard 16bits Floating Point
    bit                          XF16;
    // Non standard 16bits Floating Point Alt
    bit                          XF16ALT;
    // Non standard 8bits Floating Point
    bit                          XF8;
    // Atomic RISC-V extension
    bit                          RVA;
    // Bit manipulation RISC-V extension
    bit                          RVB;
    // Vector RISC-V extension
    bit                          RVV;
    // Compress RISC-V extension
    bit                          RVC;
    // Zcb RISC-V extension
    bit                          RVZCB;
    // Zcmp RISC-V extension
    bit                          RVZCMP;
    // Non standard Vector Floating Point
    bit                          XFVec;
    // CV-X-IF coprocessor interface is supported
    bit                          CvxifEn;
    // Zicond RISC-V extension
    bit                          ZiCondExtEn;
    // Supervisor mode
    bit                          RVS;
    // User mode
    bit                          RVU;
    // Scoreboard length
    int unsigned                 NrScoreboardEntries;
    // Address to jump when halt request
    logic [63:0]                 HaltAddress;
    // Address to jump when exception 
    logic [63:0]                 ExceptionAddress;
    // Return address stack depth
    int unsigned                 RASDepth;
    // Branch target buffer entries
    int unsigned                 BTBEntries;
    // Branch history entries
    int unsigned                 BHTEntries;
    // Base address of the debug module
    logic [63:0]                 DmBaseAddress;
    // Tval Support Enable
    bit                          TvalEn;
    // Number of PMP entries
    int unsigned                 NrPMPEntries;
    // PMP CSR configuration reset values
    logic [15:0][63:0]           PMPCfgRstVal;
    // PMP CSR address reset values
    logic [15:0][63:0]           PMPAddrRstVal;
    // PMP CSR read-only bits
    bit [15:0]                   PMPEntryReadOnly;
    // NOC bus type
    noc_type_e                   NOCType;
    // Number of PMA non idempotent rules
    int unsigned                 NrNonIdempotentRules;
    // PMA NonIdempotent region base address
    logic [NrMaxRules-1:0][63:0] NonIdempotentAddrBase;
    // PMA NonIdempotent region length
    logic [NrMaxRules-1:0][63:0] NonIdempotentLength;
    // Number of PMA regions with execute rules
    int unsigned                 NrExecuteRegionRules;
    // PMA Execute region base address
    logic [NrMaxRules-1:0][63:0] ExecuteRegionAddrBase;
    // PMA Execute region address base
    logic [NrMaxRules-1:0][63:0] ExecuteRegionLength;
    // Number of PMA regions with cache rules
    int unsigned                 NrCachedRegionRules;
    // PMA cache region base address
    logic [NrMaxRules-1:0][63:0] CachedRegionAddrBase;
    // PMA cache region rules
    logic [NrMaxRules-1:0][63:0] CachedRegionLength;
    // Maximum number of outstanding stores
    int unsigned                 MaxOutstandingStores;
    // Debug support
    bit                          DebugEn;
    // AXI burst in write
    bit                          AxiBurstWriteEn;
    // Instruction cache size (in bytes)
    int unsigned                 IcacheByteSize;
    // Instruction cache associativity (number of ways)
    int unsigned                 IcacheSetAssoc;
    // Instruction line width
    int unsigned                 IcacheLineWidth;
    // Data cache size (in bytes)
    int unsigned                 DcacheByteSize;
    // Data cache associativity (number of ways)
    int unsigned                 DcacheSetAssoc;
    // Data line width
    int unsigned                 DcacheLineWidth;
    // TODO
    int unsigned                 DataUserEn;
    // TODO
    int unsigned                 FetchUserWidth;
    // TODO
    int unsigned                 FetchUserEn;
  } cva6_user_cfg_t;

  typedef struct packed {
    bit          RVC;
    int unsigned FETCH_WIDTH;
    int unsigned INSTR_PER_FETCH;
    int unsigned LOG2_INSTR_PER_FETCH;
    int unsigned XLEN;
  } cva6_cfg_t;

  /// Empty configuration to sanity check proper parameter passing. Whenever
  /// you develop a module that resides within the core, assign this constant.
  localparam cva6_cfg_t cva6_cfg_empty = '0;

endpackage

package build_config_pkg;

  function automatic config_pkg::cva6_cfg_t build_config(config_pkg::cva6_user_cfg_t CVA6Cfg);
    config_pkg::cva6_cfg_t cfg;
    cfg.RVC = CVA6Cfg.RVC;
    cfg.FETCH_WIDTH = 32;
    cfg.INSTR_PER_FETCH = CVA6Cfg.RVC == 1'b1 ? (cfg.FETCH_WIDTH / 16) : 1;
    cfg.LOG2_INSTR_PER_FETCH = CVA6Cfg.RVC == 1'b1 ? $clog2(cfg.INSTR_PER_FETCH) : 1;
    return cfg;
  endfunction

endpackage


module top();
 //parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty;

 parameter config_pkg::cva6_cfg_t CVA6Cfg = build_config_pkg::build_config(
        cva6_config_pkg::cva6_cfg);

 popcount #(
        .INPUT_WIDTH(CVA6Cfg.INSTR_PER_FETCH)
    ) u1();

endmodule

module popcount #(parameter int unsigned INPUT_WIDTH = 2) ();
endmodule
