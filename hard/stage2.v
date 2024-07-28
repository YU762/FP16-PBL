`ifdef ENABLE_FPU
  output wire                                 h_ex1_d_s,
  output wire [4:0]                           h_ex1_d_exp,
  output wire [11+`PEXT:0]                    h_ex1_d_csa_s,
  output wire [11+`PEXT:0]                    h_ex1_d_csa_c,
  output wire                                 h_ex1_d_zero,
  output wire                                 h_ex1_d_inf,
  output wire                                 h_ex1_d_nan,
  output wire                                 h_fadd_s1_s,
  output wire [4:0]                           h_fadd_s1_exp,
  output wire [11+`PEXT:0]                    h_fadd_s1_frac,
  output wire                                 h_fadd_s1_zero,
  output wire                                 h_fadd_s1_inf,
  output wire                                 h_fadd_s1_nan,
  output wire                                 l_ex1_d_s,
  output wire [4:0]                           l_ex1_d_exp,
  output wire [11+`PEXT:0]                    l_ex1_d_csa_s,
  output wire [11+`PEXT:0]                    l_ex1_d_csa_c,
  output wire                                 l_ex1_d_zero,
  output wire                                 l_ex1_d_inf,
  output wire                                 l_ex1_d_nan,
  output wire                                 l_fadd_s1_s,
  output wire [4:0]                           l_fadd_s1_exp,
  output wire [11+`PEXT:0]                    l_fadd_s1_frac,
  output wire                                 l_fadd_s1_zero,
  output wire                                 l_fadd_s1_inf,
  output wire                                 l_fadd_s1_nan,
`endif

`ifdef ENABLE_FPU

  function [3:0] cuti4;
    input [`EXE_WORD_BITS-1:0] i16;
    input [2:0] idx;
    reg   [3:0] d;
    begin
      case (idx[2:0])
        3'h0:    d = i16[ 3: 0];
        3'h1:    d = i16[ 7: 4];
        3'h2:    d = i16[11: 8];
        3'h3:    d = i16[15:12];
        default: d = 4'h0;
      endcase
      cuti4 = d;
    end
  endfunction

  function [`EXE_WORD_BITS-1:0] i4tof16;
    input [3:0] i4;
    reg   [7:0] d;
    begin
      case (i4[3:0])
        4'h0:    d = 8'h88; 
        4'h1:    d = 8'h86; 
        4'h2:    d = 8'h84; 
        4'h3:    d = 8'h82; 
        4'h4:    d = 8'h80; 
        4'h5:    d = 8'h7c; 
        4'h6:    d = 8'h78; 
        4'h7:    d = 8'h74;
        4'h8:    d = 8'h00; 
        4'h9:    d = 8'h34; 
        4'ha:    d = 8'h38; 
        4'hb:    d = 8'h3c; 
        4'hc:    d = 8'h40; 
        4'hd:    d = 8'h42;
        4'he:    d = 8'h44; 
        default: d = 8'h46; 
      endcase
      i4tof16 = {d,8'h00};
    end
  endfunction

  wire [1:0]                fop  = (`conf_op1==`OP_FMA || `conf_op1==`OP_CFMA)  ? 2'h0:
                                   (`conf_op1==`OP_FMS)  ? 2'h1:
                                   (`conf_op1==`OP_FAD)  ? 2'h2:
                                                          2'h3;

  wire [`REG_DATA_BITS-1:0] itof = {i4tof16(cuti4(iex2[31:16],iex3[18:16])),i4tof16(cuti4(iex2[15:0],iex3[2:0]))};
   
  wire [`REG_DATA_BITS-1:0] fex1 = (`conf_op1==`OP_FML || `conf_op1==`OP_FML3)  ? 0:iex1;

  wire [`REG_DATA_BITS-1:0] fex2 = (`conf_op1==`OP_FML || `conf_op1==`OP_FML3)  ? iex1:iex2;

  wire [`REG_DATA_BITS-1:0] fex3 = (`conf_op1==`OP_FMA || `conf_op1==`OP_CFMA)  ? iex3:
                                   (`conf_op1==`OP_FMS)  ? iex3:
                                   (`conf_op1==`OP_FML)  ? iex2:
                                   (`conf_op1==`OP_FML3) ? itof:
                                                           32'h3C00_3C00;

  wire 	                    cfma_force0 = `conf_op1==`OP_CFMA && 
                                         ((fex2[`REG_DATA_BITS-1:`EXE_WORD_BITS] == {(`EXE_WORD_BITS){1'b1}}) ||
                                          (fex2[`REG_DATA_BITS-1:`EXE_WORD_BITS] != fex3[`REG_DATA_BITS-1:`EXE_WORD_BITS]));

  fpu1 fpu1h
  (
    .ACLK               (ACLK                   ),
    .RSTN               (RSTN&UNIRSTN           ),
    .op                 (fop                    ),
    .ex1                (fex1[31:16]            ),
    .ex2                (fex2[31:16]            ),
    .ex3                (fex3[31:16]            ),
    .force0             (1'b0                   ),
    .ex1_d_s            (h_ex1_d_s              ),
    .ex1_d_exp          (h_ex1_d_exp            ),
    .ex1_d_csa_s        (h_ex1_d_csa_s          ),
    .ex1_d_csa_c        (h_ex1_d_csa_c          ),
    .ex1_d_zero         (h_ex1_d_zero           ),
    .ex1_d_inf          (h_ex1_d_inf            ),
    .ex1_d_nan          (h_ex1_d_nan            ),
    .fadd_s1_s          (h_fadd_s1_s            ),
    .fadd_s1_exp        (h_fadd_s1_exp          ),
    .fadd_s1_frac       (h_fadd_s1_frac         ),
    .fadd_s1_zero       (h_fadd_s1_zero         ),
    .fadd_s1_inf        (h_fadd_s1_inf          ),
    .fadd_s1_nan        (h_fadd_s1_nan          )
  );

  fpu1 fpu1l
  (
    .ACLK               (ACLK                   ),
    .RSTN               (RSTN&UNIRSTN           ),
    .op                 (fop                    ),
    .ex1                (fex1[15: 0]            ),
    .ex2                (fex2[15: 0]            ),
    .ex3                (fex3[15: 0]            ),
    .force0             (cfma_force0            ),
    .ex1_d_s            (l_ex1_d_s              ),
    .ex1_d_exp          (l_ex1_d_exp            ),
    .ex1_d_csa_s        (l_ex1_d_csa_s          ),
    .ex1_d_csa_c        (l_ex1_d_csa_c          ),
    .ex1_d_zero         (l_ex1_d_zero           ),
    .ex1_d_inf          (l_ex1_d_inf            ),
    .ex1_d_nan          (l_ex1_d_nan            ),
    .fadd_s1_s          (l_fadd_s1_s            ),
    .fadd_s1_exp        (l_fadd_s1_exp          ),
    .fadd_s1_frac       (l_fadd_s1_frac         ),
    .fadd_s1_zero       (l_fadd_s1_zero         ),
    .fadd_s1_inf        (l_fadd_s1_inf          ),
    .fadd_s1_nan        (l_fadd_s1_nan          )
  );
`endif

`ifdef ENABLE_FPU
module fpu1
(
  input  wire                 ACLK,
  input  wire                 RSTN,
  input  wire [1:0]           op,
  input  wire [15:0]          ex1,
  input  wire [15:0]          ex2,
  input  wire [15:0]          ex3,
  input  wire                 force0,
  output wire                 ex1_d_s,
  output wire [4:0]           ex1_d_exp,
  output wire [11+`PEXT:0]    ex1_d_csa_s,
  output wire [11+`PEXT:0]    ex1_d_csa_c,
  output wire                 ex1_d_zero,
  output wire                 ex1_d_inf,
  output wire                 ex1_d_nan,
  output wire                 fadd_s1_s,
  output wire [4:0]           fadd_s1_exp,
  output wire [11+`PEXT:0]    fadd_s1_frac,
  output wire                 fadd_s1_zero,
  output wire                 fadd_s1_inf,
  output wire                 fadd_s1_nan
);
  wire                const_one       = 1'b1;
  wire                s1_s            = (op==2'd3)? 1'b0:ex1[15];
  wire [4:0]          s1_exp          = (op==2'd3)? 5'd0:ex1[14:10];
  wire [10:0]         s1_frac         = (op==2'd3)? 11'd0:(~(|s1_exp))?{1'b0,ex1[9:0]}:{1'b1,ex1[9:0]};
  wire                s1_zero         = (op==2'd3)? 1'b1: (~(|s1_exp)) & (~(|ex1[9:0]));
  wire                s1_inf          = (op==2'd3)? 1'b0: (  &s1_exp ) & (~(|ex1[9:0]));
  wire                s1_nan          = (op==2'd3)? 1'b0: (  &s1_exp ) & (  |ex1[9:0] );
  wire 	      	      s2_s            = (op==2'd1)?~ex2[15]:ex2[15];
  wire [4:0]          s2_exp          = ex2[14:10];
  wire [10:0]         s2_frac         = (~(|s2_exp))?{1'b0,ex2[9:0]}:{1'b1,ex2[9:0]};
  wire                s2_zero         = (~(|s2_exp)) & (~(|ex2[9:0]));
  wire                s2_inf          = (  &s2_exp ) & (~(|ex2[9:0]));
  wire                s2_nan          = (  &s2_exp ) & (  |ex2[9:0] );
  wire                s3_s            = (op==2'd2)? 1'b0   :ex3[15];
  wire [4:0]          s3_exp          = (op==2'd2)? 5'd15 :ex3[14:10];
  wire [10:0]         s3_frac         = (op==2'd2)? 11'h400:(~(|s3_exp))?{1'b0,ex3[9:0]}:{1'b1,ex3[9:0]};
  wire                s3_zero         = (op==2'd2)? 1'b0       :(~(|s3_exp)) & (~(|ex3[9:0]));
  wire                s3_inf          = (op==2'd2)? 1'b0       :(  &s3_exp ) & (~(|ex3[9:0]));
  wire                s3_nan          = (op==2'd2)? 1'b0       :(  &s3_exp ) & (  |ex3[9:0] );
  wire [21:0]         booth_s;
  wire [21:0]         booth_c;
  bit11_booth_wallace bw_impl         (.ai(s2_frac), .bi(s3_frac), .so(booth_s), .co(booth_c));
  wire                r_ex1_d_s       = force0 ? 1'b0                 : (s2_s ^ s3_s);
  wire [4:0]          r_ex1_d_exp     = force0 ? 5'd0                 : ({1'b0,s2_exp} + {1'b0,s3_exp} < 5'd15 ? 5'd0 :
                                                                         {1'b0,s2_exp} + {1'b0,s3_exp} - 5'd15);
  wire [11+`PEXT:0]   r_ex1_d_csa_s   = force0 ? {(11+`PEXT+1){1'b0}} : booth_s[22:11-`PEXT];
  wire [11+`PEXT:0]   r_ex1_d_csa_c   = force0 ? {(11+`PEXT+1){1'b0}} : booth_c[22:11-`PEXT];
  wire                r_ex1_d_zero    = force0 ? 1'b1                 : ((s2_zero && !s3_inf && !s3_nan) || (s3_zero && !s2_inf && !s2_nan));
  wire                r_ex1_d_inf     = force0 ? 1'b0                 : ((s2_inf && !s3_zero && !s3_nan) || (s3_inf && !s2_zero && !s2_nan));
  wire                r_ex1_d_nan     = force0 ? 1'b0                 : (s2_nan || s3_nan || (s2_inf && s3_zero) || (s3_inf && s2_zero));
  nbit_register #(1)  ex1_d_s_r           (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_s    ),  .q(ex1_d_s     ));
  nbit_register #(5)  ex1_d_exp_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_exp  ),  .q(ex1_d_exp   ));
  nbit_register #(12+`PEXT) ex1_d_csa_s_r (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_csa_s),  .q(ex1_d_csa_s ));
  nbit_register #(12+`PEXT) ex1_d_csa_c_r (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_csa_c),  .q(ex1_d_csa_c ));
  nbit_register #(1)  ex1_d_zero_r        (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_zero ),  .q(ex1_d_zero  ));
  nbit_register #(1)  ex1_d_inf_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_inf  ),  .q(ex1_d_inf   ));
  nbit_register #(1)  ex1_d_nan_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_nan  ),  .q(ex1_d_nan   ));
  wire                r_fadd_s1_s     = s1_s;
  wire [4:0] 	      r_fadd_s1_exp   = (5'd0<s1_exp&&s1_exp<5'd31)?{1'b0,(s1_exp-5'd1)}:{1'b0,s1_exp};
  wire [11+`PEXT:0]   r_fadd_s1_frac  = (5'd0<s1_exp&&s1_exp<5'd31)?{s1_frac,{(`PEXT+1){1'b0}}}:{1'b0,s1_frac,{(`PEXT){1'b0}}};
  wire                r_fadd_s1_zero  = s1_zero;
  wire                r_fadd_s1_inf   = s1_inf;
  wire                r_fadd_s1_nan   = s1_nan;
  nbit_register #(1)  fadd_s1_s_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_s   ),  .q(fadd_s1_s   ));
  nbit_register #(5)  fadd_s1_exp_r       (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_exp ),  .q(fadd_s1_exp ));
  nbit_register #(12+`PEXT) fadd_s1_frac_r(.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_frac),  .q(fadd_s1_frac));
  nbit_register #(1)  fadd_s1_zero_r      (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_zero),  .q(fadd_s1_zero));
  nbit_register #(1)  fadd_s1_inf_r       (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_inf ),  .q(fadd_s1_inf ));
  nbit_register #(1)  fadd_s1_nan_r       (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_nan ),  .q(fadd_s1_nan ));
endmodule
`endif