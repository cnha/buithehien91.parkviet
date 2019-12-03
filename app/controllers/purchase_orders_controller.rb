class PurchaseOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy, :status]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @per_page = params[:per_page] || PurchaseOrder.per_page || 20
    @q = PurchaseOrder.ransack(params[:q])
    @purchase_orders = @q.result.by_store(current_store.id).order('id desc').paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html {
        unless has_permission?("transaction_purchase_order_view")
          render "roles/no_permission", layout: 'home'
        end
      }
      format.json {}
    end
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show

  end

  # GET /purchase_orders/new
  def new
    @purchase_order = PurchaseOrder.new
  end

  # GET /purchase_orders/1/edit
  def edit
  end

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @purchase_order.user = current_user
    @purchase_order.store = current_store

    respond_to do |format|
      if @purchase_order.save
        @purchase_order.code = build_code("PO", @purchase_order) unless @purchase_order.code.present?
        @purchase_order.save

        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_order }
      else
        format.html { render :new }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # Update status
  def status
    if params[:status].eql?("complete")
      @purchase_order.status = :completed
      if @purchase_order.save
        redirect_to purchase_orders_path, notice: "Đã hoàn thành đặt hàng nhập"
      end
    elsif params[:status].eql?("approve")
      @purchase_order.status = :approved
      if @purchase_order.save
        redirect_to @purchase_order, notice: "Đã phê duyệt"
      end
    end
  end

  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    # @purchase_order.destroy
    @purchase_order.status = :canceled
    @purchase_order.save
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_params
      params.require(:purchase_order).permit(:name, :code, :note, :supplier_id)
    end
end
