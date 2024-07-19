`ifdef ENABLE_FPU
  output wire                                 h_ex1_d_s,
  output wire [8:0]                           h_ex1_d_exp,
  output wire [24+`PEXT:0]                    h_ex1_d_csa_s, //������
  output wire [24+`PEXT:0]                    h_ex1_d_csa_c, //������
  output wire                                 h_ex1_d_zero,
  output wire                                 h_ex1_d_inf,
  output wire                                 h_ex1_d_nan,
  output wire                                 h_fadd_s1_s,
  output wire [8:0]                           h_fadd_s1_exp,
  output wire [24+`PEXT:0]                    h_fadd_s1_frac, //������
  output wire                                 h_fadd_s1_zero,
  output wire                                 h_fadd_s1_inf,
  output wire                                 h_fadd_s1_nan,
  output wire                                 l_ex1_d_s,
  output wire [8:0]                           l_ex1_d_exp,
  output wire [24+`PEXT:0]                    l_ex1_d_csa_s, //������
  output wire [24+`PEXT:0]                    l_ex1_d_csa_c, //������
  output wire                                 l_ex1_d_zero,
  output wire                                 l_ex1_d_inf,
  output wire                                 l_ex1_d_nan,
  output wire                                 l_fadd_s1_s,
  output wire [8:0]                           l_fadd_s1_exp,
  output wire [24+`PEXT:0]                    l_fadd_s1_frac, //������
  output wire                                 l_fadd_s1_zero,
  output wire                                 l_fadd_s1_inf,
  output wire                                 l_fadd_s1_nan,
`endif

`ifdef ENABLE_FPU
  /*-------------- 32bit floating point operator ----------------------------------*/
  /* op=3->0:fma3 (ex1 + ex2 *  ex3)  */
  /* op=3->1:fms3 (ex1 - ex2 *  ex3)  */
  /* op=1->3:fmul (0.0 + ex2 *  ex3)  */
  /* op=2->2:fadd (ex1 + ex2 *  1.0)  */

   function [3:0] cuti4;
      input [`EXE_WORD_BITS-1:0] i32;
      input [2:0] idx; /* the location of 4bits in 32bit: 7,6,5,4,3,2,1,0 */
      reg   [3:0] d;
      begin
	case (idx[2:0])
	  3'h0:    d = i32[ 3: 0];
	  3'h1:    d = i32[ 7: 4];
	  3'h2:    d = i32[11: 8];
	  3'h3:    d = i32[15:12];
	  3'h4:    d = i32[19:16];
	  3'h5:    d = i32[23:20];
	  3'h6:    d = i32[27:24];
	  default: d = i32[31:28];
	endcase
	cuti4 = d;
      end
   endfunction

   function [`EXE_WORD_BITS-1:0] i4tof32;
      input [3:0] i4;
      reg   [11:0] d;
      begin
	case (i4[3:0])
	  4'h0:    d = 12'hc10; /* -8.0 */
	  4'h1:    d = 12'hc0e; /* -7.0 */
	  4'h2:    d = 12'hc0c; /* -6.0 */
	  4'h3:    d = 12'hc0a; /* -5.0 */
	  4'h4:    d = 12'hc08; /* -4.0 */
	  4'h5:    d = 12'hc04; /* -3.0 */
	  4'h6:    d = 12'hc00; /* -2.0 */
	  4'h7:    d = 12'hbf8; /* -1.0 */
	  4'h8:    d = 12'h000; /*  0.0 */
	  4'h9:    d = 12'h3f8; /*  1.0 */
	  4'ha:    d = 12'h400; /*  2.0 */
	  4'hb:    d = 12'h404; /*  3.0 */
	  4'hc:    d = 12'h408; /*  4.0 */
	  4'hd:    d = 12'h40a; /*  5.0 */
	  4'he:    d = 12'h40c; /*  6.0 */
	  default: d = 12'h40e; /*  7.0 */
	endcase
	i4tof32 = {d,20'h00000};
      end
   endfunction

  wire [1:0]                fop  = (`conf_op1==`OP_FMA || `conf_op1==`OP_CFMA)  ? 2'h0: //��MEX
				   (`conf_op1==`OP_FMS)  ? 2'h1:
                                   (`conf_op1==`OP_FAD)  ? 2'h2:
                                       /* `OP_FML/FML3 */  2'h3;

  wire [`REG_DATA_BITS-1:0] itof = {i4tof32(cuti4(iex2[63:32],iex3[34:32])),i4tof32(cuti4(iex2[31:0],iex3[2:0]))}; /* for GGML f32*i4 */
   
  wire [`REG_DATA_BITS-1:0] fex1 = (`conf_op1==`OP_FML || `conf_op1==`OP_FML3)  ? 0:iex1;

  wire [`REG_DATA_BITS-1:0] fex2 = (`conf_op1==`OP_FML || `conf_op1==`OP_FML3)  ? iex1:iex2;

  wire [`REG_DATA_BITS-1:0] fex3 = (`conf_op1==`OP_FMA || `conf_op1==`OP_CFMA)  ? iex3: //��MEX
			           (`conf_op1==`OP_FMS)  ? iex3:
                                   (`conf_op1==`OP_FML)  ? iex2:
		     	           (`conf_op1==`OP_FML3) ? itof:
                                            /* `OP_FAD */  64'h3F8000003F800000;

  wire 	                    cfma_force0 = `conf_op1==`OP_CFMA &&                                                             //��MEX
                                         ((fex2[`REG_DATA_BITS-1:`EXE_WORD_BITS] == {(`EXE_WORD_BITS){1'b1}})                //��MEX
			                ||(fex2[`REG_DATA_BITS-1:`EXE_WORD_BITS] != fex3[`REG_DATA_BITS-1:`EXE_WORD_BITS])); //��MEX

  fpu1 fpu1h
  (
    .ACLK               (ACLK                   ),
    .RSTN               (RSTN&UNIRSTN           ),
    .op                 (fop                    ),
    .ex1                (fex1[63:32]            ),
    .ex2                (fex2[63:32]            ),
    .ex3                (fex3[63:32]            ),
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
    .ex1                (fex1[31: 0]            ),
    .ex2                (fex2[31: 0]            ),
    .ex3                (fex3[31: 0]            ),
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
  input  wire [31:0]          ex1,
  input  wire [31:0]          ex2,
  input  wire [31:0]          ex3,
  input  wire                 force0,
  output wire                 ex1_d_s,
  output wire [8:0]           ex1_d_exp,
  output wire [24+`PEXT:0]    ex1_d_csa_s, //������
  output wire [24+`PEXT:0]    ex1_d_csa_c, //������
  output wire                 ex1_d_zero,
  output wire                 ex1_d_inf,
  output wire                 ex1_d_nan,
  output wire                 fadd_s1_s,
  output wire [8:0]           fadd_s1_exp,
  output wire [24+`PEXT:0]    fadd_s1_frac, //������
  output wire                 fadd_s1_zero,
  output wire                 fadd_s1_inf,
  output wire                 fadd_s1_nan
);
  wire                const_one       = 1'b1;
  wire                s1_s            = (op==2'd3)? 1'b0:ex1[31];
  wire [7:0]          s1_exp          = (op==2'd3)? 8'd0:ex1[30:23];
  wire [23:0]         s1_frac         = (op==2'd3)? 24'd0:(~(|s1_exp))?{1'b0,ex1[22:0]}:{1'b1,ex1[22:0]};
  wire                s1_zero         = (op==2'd3)? 1'b1: (~(|s1_exp)) & (~(|ex1[22:0]));
  wire                s1_inf          = (op==2'd3)? 1'b0: (  &s1_exp ) & (~(|ex1[22:0]));
  wire                s1_nan          = (op==2'd3)? 1'b0: (  &s1_exp ) & (  |ex1[22:0] );
  wire 	      	      s2_s            = (op==2'd1)?~ex2[31]:ex2[31];
  wire [7:0]          s2_exp          = ex2[30:23];
  wire [23:0]         s2_frac         = (~(|s2_exp))?{1'b0,ex2[22:0]}:{1'b1,ex2[22:0]};
  wire                s2_zero         = (~(|s2_exp)) & (~(|ex2[22:0]));
  wire                s2_inf          = (  &s2_exp ) & (~(|ex2[22:0]));
  wire                s2_nan          = (  &s2_exp ) & (  |ex2[22:0] );
  wire                s3_s            = (op==2'd2)? 1'b0   :ex3[31];
  wire [7:0]          s3_exp          = (op==2'd2)? 8'd127 :ex3[30:23];
  wire [23:0]         s3_frac         = (op==2'd2)? 24'h80_0000:(~(|s3_exp))?{1'b0,ex3[22:0]}:{1'b1,ex3[22:0]};
  wire                s3_zero         = (op==2'd2)? 1'b0       :(~(|s3_exp)) & (~(|ex3[22:0]));
  wire                s3_inf          = (op==2'd2)? 1'b0       :(  &s3_exp ) & (~(|ex3[22:0]));
  wire                s3_nan          = (op==2'd2)? 1'b0       :(  &s3_exp ) & (  |ex3[22:0] );
  wire [47:0]         booth_s;
  wire [47:0]         booth_c;
  bit24_booth_wallace bw_impl         (.ai(s2_frac), .bi(s3_frac), .so(booth_s), .co(booth_c));
  wire                r_ex1_d_s       = force0 ? 1'b0                 : (s2_s ^ s3_s);                                                              //��WEX
  wire [8:0]          r_ex1_d_exp     = force0 ? 9'd0                 : ({1'b0,s2_exp} + {1'b0,s3_exp} < 9'd127 ? 9'd0 :                            //��WEX
                                                                         {1'b0,s2_exp} + {1'b0,s3_exp} - 9'd127);                                   //��WEX
  wire [24+`PEXT:0]   r_ex1_d_csa_s   = force0 ? {(24+`PEXT+1){1'b0}} : booth_s[47:23-`PEXT]; /* sum   �����Ǵݤ�������Ф� (FMA�θ³�) */ //������ //��WEX
  wire [24+`PEXT:0]   r_ex1_d_csa_c   = force0 ? {(24+`PEXT+1){1'b0}} : booth_c[47:23-`PEXT]; /* carry �����Ǵݤ�������Ф� (FMA�θ³�) */ //������ //��WEX
  wire                r_ex1_d_zero    = force0 ? 1'b1                 : ((s2_zero && !s3_inf && !s3_nan) || (s3_zero && !s2_inf && !s2_nan));       //��WEX
  wire                r_ex1_d_inf     = force0 ? 1'b0                 : ((s2_inf && !s3_zero && !s3_nan) || (s3_inf && !s2_zero && !s2_nan));       //��WEX
  wire                r_ex1_d_nan     = force0 ? 1'b0                 : (s2_nan || s3_nan || (s2_inf && s3_zero) || (s3_inf && s2_zero));           //��WEX
  nbit_register #(1)  ex1_d_s_r           (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_s    ),  .q(ex1_d_s     ));  //slice 1
  nbit_register #(9)  ex1_d_exp_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_exp  ),  .q(ex1_d_exp   ));  //slice 1
  nbit_register #(25+`PEXT) ex1_d_csa_s_r (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_csa_s),  .q(ex1_d_csa_s ));  //slice 1 //������
  nbit_register #(25+`PEXT) ex1_d_csa_c_r (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_csa_c),  .q(ex1_d_csa_c ));  //slice 1 //������
  nbit_register #(1)  ex1_d_zero_r        (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_zero ),  .q(ex1_d_zero  ));  //slice 1
  nbit_register #(1)  ex1_d_inf_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_inf  ),  .q(ex1_d_inf   ));  //slice 1
  nbit_register #(1)  ex1_d_nan_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_ex1_d_nan  ),  .q(ex1_d_nan   ));  //slice 1
  wire                r_fadd_s1_s     = s1_s;
  wire [8:0] 	      r_fadd_s1_exp   = (8'd0<s1_exp&&s1_exp<8'd255)?{1'b0,(s1_exp-8'd1)}:{1'b0,s1_exp};
  wire [24+`PEXT:0]   r_fadd_s1_frac  = (8'd0<s1_exp&&s1_exp<8'd255)?{s1_frac,{(`PEXT+1){1'b0}}}:{1'b0,s1_frac,{(`PEXT){1'b0}}}; //������
  wire                r_fadd_s1_zero  = s1_zero;
  wire                r_fadd_s1_inf   = s1_inf;
  wire                r_fadd_s1_nan   = s1_nan;
  nbit_register #(1)  fadd_s1_s_r         (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_s   ),  .q(fadd_s1_s   ));  //slice 1
  nbit_register #(9)  fadd_s1_exp_r       (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_exp ),  .q(fadd_s1_exp ));  //slice 1
  nbit_register #(25+`PEXT) fadd_s1_frac_r(.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_frac),  .q(fadd_s1_frac));  //slice 1 //������
  nbit_register #(1)  fadd_s1_zero_r      (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_zero),  .q(fadd_s1_zero));  //slice 1
  nbit_register #(1)  fadd_s1_inf_r       (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_inf ),  .q(fadd_s1_inf ));  //slice 1
  nbit_register #(1)  fadd_s1_nan_r       (.ACLK(ACLK), .RSTN(RSTN), .d(r_fadd_s1_nan ),  .q(fadd_s1_nan ));  //slice 1
endmodule
`endif