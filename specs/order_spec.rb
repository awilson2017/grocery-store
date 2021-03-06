require 'csv'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'
require_relative '../lib/order'
#
describe "Order Wave 1" do
  describe "#initialize" do
    it "Takes an ID and collection of products" do
      id = 1337
      order = Grocery::Order.new(id, {})

      order.must_respond_to :id
      order.id.must_equal id
      order.id.must_be_kind_of Integer

      order.must_respond_to :products
      order.products.length.must_equal 0
    end
  end

  describe "#total" do
    it "Returns the total from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      sum = products.values.inject(0, :+)
      expected_total = sum + (sum * 0.075).round(2)

      order.total.must_equal expected_total
    end

    it "Returns a total of zero if there are no products" do
      order = Grocery::Order.new(1337, {})

      order.total.must_equal 0
    end
  end

  describe "#add_product" do
    it "Increases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Grocery::Order.new(1337, products)

      order.add_product("salad", 4.25)
      expected_count = before_count + 1
      order.products.count.must_equal expected_count
    end

    it "Is added to the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      order.add_product("sandwich", 4.25)
      order.products.include?("sandwich").must_equal true
    end

    it "Returns false if the product is already present" do
      products = { "banana" => 1.99, "cracker" => 3.00 }

      order = Grocery::Order.new(1337, products)
      before_total = order.total

      result = order.add_product("banana", 4.25)
      after_total = order.total

      result.must_equal false
      before_total.must_equal after_total
    end

    it "Returns true if the product is new" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      result = order.add_product("salad", 4.25)
      result.must_equal true
    end
  end
  #
  describe "#delete_product" do
    it "Decreases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Grocery::Order.new(1337, products)

      order.remove_product("banana")
      expected_count = before_count - 1
      order.products.count.must_equal expected_count
    end

    it "Is deleted to the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      order.remove_product("banana")
      order.products.include?("banana").must_equal false
    end

    it "Returns true if the product was successfully removed" do
      products = { "banana" => 1.99, "cracker" => 3.00 }

      order = Grocery::Order.new(1337, products)
      before_total = order.total

      result = order.remove_product("banana")
      after_total = order.total

      result.must_equal true
      before_total.must_be :>, after_total
    end

    it "Returns false if the product was not removed" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      result = order.remove_product("salad")
      result.must_equal false
    end
  end
end

# TODO: change 'xdescribe' to 'describe' to run these tests
describe "Order Wave 2" do
  describe "Order.all" do

    it "Returns an array" do
      result = Grocery::Order.all
      result.must_be_kind_of Array
    end

    it "Returns an order object" do
      Grocery::Order.all[0].must_be_kind_of Grocery::Order
    end

    it "Get Order ID and products of both the first and last order" do
      products_1 = {"Slivered Almonds" => 22.88, "Wholewheat flour" => 1.93, "Grape Seed Oil" => 74.9}

      products_100 = {"Allspice"=>64.74, "Bran"=>14.72, "UnbleachedFlour"=>80.59}

      result = Grocery::Order.all


      # testing first order's id and products
      result.first.id.must_equal 1
      result.first.products.must_equal products_1

      # testing last order's id and products
      result.last.id.must_equal 100
      result.last.products.must_equal products_100
    end

    it "Verifies the number of orders is correct" do
      fixture_count = CSV.read("support/orders.csv", 'r').length


      # Implicit way to write a test
      Grocery::Order.all.count.must_equal fixture_count
    end
  end # describe '.all'


  describe "Order.find" do
    it "Can find the first order object via id and products from the CSV" do

      # csv = get_csv_id
      csv_id = 1
      products_1 = {"Slivered Almonds" => 22.88, "Wholewheat flour" => 1.93, "Grape Seed Oil" => 74.9}
      Grocery::Order.find(1).id.must_equal csv_id
      Grocery::Order.find(1).products.must_equal products_1
    end

    it "Can find the last order from the CSV" do
      csv_id = 100
      Grocery::Order.find(100).id.must_equal csv_id
    end

    it "Raises an error for an order that doesn't exist" do
      proc{Grocery::Order.find(107)}.must_raise ArgumentError
    end
  end
end # end wave 2
