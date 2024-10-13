// module axi_lite
// #(  parameter pADDR_WIDTH = 12,
//     parameter pDATA_WIDTH = 32,
//     parameter Tape_Num    = 11,
//     parameter RAM_ADDR    = $clog2(Tape_Num)
// )
// (
//     output  wire                     awready,
//     output  wire                     wready,
//     input   wire                     awvalid,
//     input   wire [(pADDR_WIDTH-1):0] awaddr,
//     input   wire                     wvalid,
//     input   wire [(pDATA_WIDTH-1):0] wdata,
//     output  wire                     arready,
//     input   wire                     rready,
//     input   wire                     arvalid,
//     input   wire [(pADDR_WIDTH-1):0] araddr,
//     output  wire                     rvalid,
//     output  wire [(pDATA_WIDTH-1):0] rdata,

//     output  wire [3:0]               tap_WE,
//     output  wire                     tap_EN,
//     output  wire [(pDATA_WIDTH-1):0] tap_Di,
//     output  wire [(pADDR_WIDTH-1):0] tap_A,
//     input   wire [(pDATA_WIDTH-1):0] tap_Do,

//     output wire                      ap_start,
//     input  wire                      ap_idle,
//     input  wire                      ap_done,
//     output wire  [(pDATA_WIDTH-1):0] data_length,

//     input  wire     [(RAM_ADDR-1):0] FIR_raddr,
//     output wire  [(pDATA_WIDTH-1):0] FIR_rdata,

//     output wire                      reading_status,
//     input   wire                     axis_clk,
//     input   wire                     axis_rst_n
// );
//     wire aw_hs;
//     wire w_hs;
//     wire ar_hs;
//     reg ar_hs_reg, ar_hs_reg_delay;
//     wire r_hs;

//     reg [(pDATA_WIDTH-1):0] araddr_reg;

//     reg rvalid_reg;
//     // reg arready_reg;
//     reg [(pDATA_WIDTH-1):0] rdata_wire, rdata_reg;

//     reg [3:0]           tap_WE_reg;
//     reg                 tap_EN_reg;
//     reg [(pADDR_WIDTH-1):0] tap_A_reg;
//     reg [(pDATA_WIDTH-1):0] tap_Di_reg;

//     reg [(pDATA_WIDTH-1):0] data_length_reg;
//     reg               [7:0] ap_control;

//     reg [1:0] state_r;
//     reg [1:0] state_w;
//     localparam IDLE = 2'b00;
//     localparam WAIT = 2'b01;
//     localparam CAL  = 2'b10;
    
//     localparam INVALID_DATA = 32'hffffffff;

//     always@(posedge axis_clk or negedge axis_rst_n) begin
//         if(~axis_rst_n) begin
//             state_r <= IDLE;
//         end
//         else begin
//             state_r <= state_w;
//         end
//     end


//     always@* begin
//         case(state_r)
//             IDLE: begin
//                 tap_Di_reg  = 0;
//             end
//             WAIT: begin
//                 if (w_hs & (awaddr >= 12'h020 & awaddr <= 12'h0FF)) begin
//                     tap_Di_reg = wdata;
//                 end
//                 else begin
//                     tap_Di_reg  = 0;
//                 end
//             end
//             CAL: begin
//                 tap_Di_reg  = 0;
//             end
//             default: begin
//                 tap_Di_reg  = 0;
//             end
//         endcase
//     end


//     always@(posedge axis_clk or negedge axis_rst_n) begin
//         if (~axis_rst_n) begin
//             ap_control <= 8'b0;
//             data_length_reg <= 32'b0;
//         end
//         else begin
//             case(state_r)
//                 IDLE: begin
//                     ap_control <= {5'b0,ap_idle,ap_done,1'b0};
//                     data_length_reg <= 32'b0;
//                 end
//                 WAIT: begin
//                     ap_control[1] <= ap_done;
//                     ap_control[2] <= ap_idle;
//                     if (w_hs) begin
//                         if (awaddr == 12'h000) begin
//                             ap_control[0] <= wdata[0];
//                         end
//                         else if (awaddr == 12'h010) begin
//                             data_length_reg <= wdata;
//                         end
//                         else begin
//                             ap_control[0]  <= ap_control[0];
//                             data_length_reg <= data_length_reg;
//                         end
//                     end
//                     else begin
//                         ap_control[0]  <= ap_control[0];
//                         data_length_reg <= data_length_reg;
//                     end
//                 end
//                 CAL: begin
//                     ap_control[0] <= 0;
//                     ap_control[1] <= ap_done;
//                     ap_control[2] <= ap_idle;
//                     data_length_reg <= data_length_reg;
//                 end
//             endcase
//         end
//     end

//     wire [(pADDR_WIDTH-1):0] araddr_now = (ar_hs_reg)?araddr_reg:araddr;

//     always@* begin
//         case(state_r)
//             IDLE: begin
//                 tap_A_reg = 0;
//             end
//             WAIT: begin
//                 if (aw_hs) begin
//                     if ((awaddr >= 12'h020 & awaddr <= 12'h0FF)) begin
//                         tap_A_reg = {4'b00, awaddr[0+:7]-8'h020};
//                     end
//                     else begin
//                         tap_A_reg = 0;
//                     end
//                 end
//                 else if (ar_hs) begin
//                     if ((araddr >= 12'h020 & araddr <= 12'h0FF)) begin
//                         tap_A_reg = {4'b00, araddr[0+:7]-8'h020};
//                     end
//                     else begin
//                         tap_A_reg = 0;
//                     end
//                 end
//                 else begin
//                     tap_A_reg = 0;
//                 end
//             end
//             CAL: begin
//                 tap_A_reg = {6'b0, FIR_raddr[3:0], 2'b00};
//             end
//             default: begin
//                 tap_A_reg = 0;
//             end
//         endcase
//     end

//     assign reading_status = (ar_hs_reg) * (araddr_reg == 12'h000);
//     always@* begin
//         rdata_wire = rdata_reg;
//         if(ar_hs_reg) begin
//             if (araddr_reg == 12'h000) begin
//                 rdata_wire = ap_control;
//             end
//             else if (araddr_reg == 12'h010) begin
//                 rdata_wire = data_length;
//             end
//             else if (araddr_reg >= 12'h020 & araddr_reg <= 12'h0FF) begin
//                 rdata_wire = tap_Do;
//             end
//             else begin
//                 rdata_wire = 0;
//             end
//         end
//     end
//     always@(posedge axis_clk or negedge axis_rst_n) begin
//         if(~axis_rst_n) begin
//             rdata_reg <= 0;
//         end
//         else begin
//             rdata_reg <= (ar_hs_reg)?rdata_wire:rdata_reg;
//         end
//     end

//     always@* begin
//         case (state_r)
//             IDLE: begin
//                 tap_WE_reg = 4'b0000;
//                 tap_EN_reg = 0;
//             end
//             WAIT: begin
//                 if (w_hs & (awaddr >= 12'h020 & awaddr <= 12'h0FF)) begin
//                     tap_WE_reg = 4'b1111;
//                 end
//                 else begin
//                     tap_WE_reg = 4'b0000;
//                 end
//                 tap_EN_reg = 1;
//             end
//             CAL: begin
//                 tap_WE_reg = 4'b0000;
//                 tap_EN_reg = 1;
//             end
//             default: begin
//                 tap_WE_reg = 4'b0000;
//                 tap_EN_reg = 0;
//             end
//         endcase
//     end

//     always@* begin
//         case (state_r)
//             IDLE: begin
//                 state_w = WAIT;
//             end
//             WAIT: begin
//                 if (ap_control[0]) begin
//                     state_w = CAL;
//                 end
//                 else begin
//                     state_w = WAIT;
//                 end
//             end
//             CAL: begin
//                 if (ap_control[1]) begin
//                     state_w = WAIT;
//                 end
//                 else begin
//                     state_w = CAL;
//                 end
//             end
//             default: begin
//                 state_w = IDLE;
//             end
//         endcase
//     end

//     always@(posedge axis_clk or negedge axis_rst_n) begin
//         if (~axis_rst_n)
//             rvalid_reg <= 0;
//         else
//             rvalid_reg <= (ar_hs_reg_delay & rready);
//     end

//     always@(posedge axis_clk or negedge axis_rst_n) begin
//         if (~axis_rst_n) begin
//             ar_hs_reg <= 0;
//             ar_hs_reg_delay <= 0;
//             araddr_reg <= 0;
//         end
//         else begin
//             ar_hs_reg <= 
//                 (rready&&ar_hs_reg_delay)?
//                 0:
//                 ((ar_hs)?1:ar_hs_reg);
//             ar_hs_reg_delay <= ar_hs_reg;
//             araddr_reg <= (ar_hs)?araddr:araddr_reg;
//         end
//     end

//     assign awready = ((state_r == WAIT) & awvalid & wvalid);
//     assign wready  = ((state_r == WAIT) & awvalid & wvalid);
//     assign aw_hs = awvalid & awready;
//     assign w_hs  = wvalid  & wready;

//     assign arready = ((state_r == WAIT | state_r == CAL) & arvalid);
//     assign rvalid  = rvalid_reg;
//     assign ar_hs = arvalid & arready;
//     assign r_hs  = rvalid  & rready;
//     assign rdata  = ((state_r!=WAIT) && (araddr_reg>=12'h020)) ? INVALID_DATA : rdata_wire;

//     assign data_length = data_length_reg;

//     assign tap_EN = tap_EN_reg;
//     assign tap_WE = tap_WE_reg;
//     assign tap_Di = tap_Di_reg;
//     assign tap_A  = tap_A_reg;

//     assign ap_start = ap_control[0];
//     assign FIR_rdata = tap_Do;

// endmodule

`timescale 1ns / 1ps

module axi_lite
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11,
    parameter RAM_ADDR    = $clog2(Tape_Num)
)
(
    output  wire                     awready,
    output  wire                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  wire                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  wire                     rvalid,
    output  wire [(pDATA_WIDTH-1):0] rdata,

    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  wire [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    output wire                      ap_start,
    input  wire                      ap_idle,
    input  wire                      ap_done,
    output wire  [(pDATA_WIDTH-1):0] data_length,

    input  wire     [(RAM_ADDR-1):0] FIR_raddr,
    output wire  [(pDATA_WIDTH-1):0] FIR_rdata,

    output wire                      reading_status,
    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);
    wire aw_hs;
    wire w_hs;
    wire ar_hs;
    reg ar_hs_reg;
    wire r_hs;

    reg [(pDATA_WIDTH-1):0] araddr_reg;

    reg rvalid_reg, rvalid_reg_delay;
    reg arready_reg;
    reg [(pDATA_WIDTH-1):0] rdata_wire, rdata_reg;

    reg [3:0]           tap_WE_reg;
    reg                 tap_EN_reg;
    reg [(pADDR_WIDTH-1):0] tap_A_reg;
    reg [(pDATA_WIDTH-1):0] tap_Di_reg;

    reg [(pDATA_WIDTH-1):0] data_length_reg;
    reg               [7:0] ap_control;

    reg [1:0] state_r;
    reg [1:0] state_w;
    localparam IDLE = 2'b00;
    localparam WAIT = 2'b01;
    localparam CAL  = 2'b10;
    
    localparam INVALID_DATA = 32'hffffffff;

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(~axis_rst_n) begin
            state_r <= IDLE;
        end
        else begin
            state_r <= state_w;
        end
    end


    always@* begin
        case(state_r)
            IDLE: begin
                tap_Di_reg  = 0;
            end
            WAIT: begin
                if (w_hs & (awaddr >= 12'h020 & awaddr <= 12'h0FF)) begin
                    tap_Di_reg = wdata;
                end
                else begin
                    tap_Di_reg  = 0;
                end
            end
            CAL: begin
                tap_Di_reg  = 0;
            end
            default: begin
                tap_Di_reg  = 0;
            end
        endcase
    end


    always@(posedge axis_clk or negedge axis_rst_n) begin
        if (~axis_rst_n) begin
            ap_control <= 8'b0;
            data_length_reg <= 32'b0;
        end
        else begin
            case(state_r)
                IDLE: begin
                    ap_control <= {5'b0,ap_idle,ap_done,1'b0};
                    data_length_reg <= 32'b0;
                end
                WAIT: begin
                    ap_control[1] <= ap_done;
                    ap_control[2] <= ap_idle;
                    if (w_hs) begin
                        if (awaddr == 12'h000) begin
                            ap_control[0] <= wdata[0];
                        end
                        else if (awaddr == 12'h010) begin
                            data_length_reg <= wdata;
                        end
                        else begin
                            ap_control[0]  <= ap_control[0];
                            data_length_reg <= data_length_reg;
                        end
                    end
                    else begin
                        ap_control[0]  <= ap_control[0];
                        data_length_reg <= data_length_reg;
                    end
                end
                CAL: begin
                    ap_control[0] <= 0;
                    ap_control[1] <= ap_done;
                    ap_control[2] <= ap_idle;
                    data_length_reg <= data_length_reg;
                end
            endcase
        end
    end

    wire [(pADDR_WIDTH-1):0] araddr_now = (ar_hs_reg)?araddr_reg:araddr;

    always@* begin
        case(state_r)
            IDLE: begin
                tap_A_reg = 0;
            end
            WAIT: begin
                if (aw_hs) begin
                    if ((awaddr >= 12'h020 & awaddr <= 12'h0FF)) begin
                        tap_A_reg = {4'b00, awaddr[0+:7]-8'h020};
                    end
                    else begin
                        tap_A_reg = 0;
                    end
                end
                else if (ar_hs) begin
                    if ((araddr >= 12'h020 & araddr <= 12'h0FF)) begin
                        tap_A_reg = {4'b00, araddr[0+:7]-8'h020};
                    end
                    else begin
                        tap_A_reg = 0;
                    end
                end
                else begin
                    tap_A_reg = 0;
                end
            end
            CAL: begin
                tap_A_reg = {6'b0, FIR_raddr[3:0], 2'b00};
            end
            default: begin
                tap_A_reg = 0;
            end
        endcase
    end

    assign reading_status = (ar_hs_reg) * (araddr_reg == 12'h000);
    always@* begin
        rdata_wire = rdata_reg;
        if(ar_hs_reg) begin
            if (araddr_reg == 12'h000) begin
                rdata_wire = ap_control;
            end
            else if (araddr_reg == 12'h010) begin
                rdata_wire = data_length;
            end
            else if (araddr_reg >= 12'h020 & araddr_reg <= 12'h0FF) begin
                rdata_wire = tap_Do;
            end
            else begin
                rdata_wire = 0;
            end
        end
    end
    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(~axis_rst_n) begin
            rdata_reg <= 0;
        end
        else begin
            rdata_reg <= (ar_hs_reg)?rdata_wire:rdata_reg;
        end
    end

    always@* begin
        case (state_r)
            IDLE: begin
                tap_WE_reg = 4'b0000;
                tap_EN_reg = 0;
            end
            WAIT: begin
                if (w_hs & (awaddr >= 12'h020 & awaddr <= 12'h0FF)) begin
                    tap_WE_reg = 4'b1111;
                end
                else begin
                    tap_WE_reg = 4'b0000;
                end
                tap_EN_reg = 1;
            end
            CAL: begin
                tap_WE_reg = 4'b0000;
                tap_EN_reg = 1;
            end
            default: begin
                tap_WE_reg = 4'b0000;
                tap_EN_reg = 0;
            end
        endcase
    end

    always@* begin
        case (state_r)
            IDLE: begin
                state_w = WAIT;
            end
            WAIT: begin
                if (ap_control[0]) begin
                    state_w = CAL;
                end
                else begin
                    state_w = WAIT;
                end
            end
            CAL: begin
                if (ap_control[1]) begin
                    state_w = WAIT;
                end
                else begin
                    state_w = CAL;
                end
            end
            default: begin
                state_w = IDLE;
            end
        endcase
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if (~axis_rst_n) begin
            rvalid_reg <= 0;
            rvalid_reg_delay <= 0;
        end
        else begin
            rvalid_reg <= (ar_hs_reg & rready);
            rvalid_reg_delay <= rvalid_reg;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if (~axis_rst_n) begin
            ar_hs_reg <= 0;
            araddr_reg <= 0;
        end
        else begin
            // ar_hs_reg <= (rready & ar_hs_reg | rvalid_reg_delay | rvalid_reg)?0:((ar_hs)?1:ar_hs_reg);
            ar_hs_reg <= (rready & ar_hs_reg | rvalid_reg)?0:((ar_hs)?1:ar_hs_reg);
            araddr_reg <= (ar_hs)?araddr:araddr_reg;
        end
    end

    assign awready = ((state_r == WAIT) & awvalid & wvalid);
    assign wready  = ((state_r == WAIT) & awvalid & wvalid);
    assign aw_hs = awvalid & awready;
    assign w_hs  = wvalid  & wready;

    assign arready = ((state_r == WAIT | state_r == CAL) & arvalid & (~(ar_hs_reg|rvalid_reg|rvalid_reg_delay)));
    assign rvalid  = (araddr_reg >= 12'h020)?(rvalid_reg_delay):(rvalid_reg);
    assign ar_hs = arvalid & arready;
    assign r_hs  = rvalid  & rready;
    assign rdata  = ((state_r!=WAIT) && (araddr_reg>=12'h020)) ? INVALID_DATA : rdata_wire;

    assign data_length = data_length_reg;

    assign tap_EN = tap_EN_reg;
    assign tap_WE = tap_WE_reg;
    assign tap_Di = tap_Di_reg;
    assign tap_A  = tap_A_reg;

    assign ap_start = ap_control[0];
    assign FIR_rdata = tap_Do;

endmodule
