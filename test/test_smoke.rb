require 'json'
require 'minitest/autorun'

class SmokeFilter < Minitest::Test
  def test_no_conditions
    r = `cat test/access.log | ./apache-log-geo | wc -l`.strip
    assert_equal "48", r
  end

  def test_by_country_code
    r = `cat test/access.log | ./apache-log-geo --cc ie | wc -l`.strip
    assert_equal "8", r
    r = `cat test/access.log | ./apache-log-geo --cc 'ie|de' | wc -l`.strip
    assert_equal "11", r
  end

  def test_by_country_code_and_city
    r = `cat test/access.log | ./apache-log-geo --cc ie --city dublin | wc -l`.strip
    assert_equal "8", r
    r = `cat test/access.log | ./apache-log-geo -v --cc ie --city dublin | wc -l`.strip
    assert_equal "40", r
  end

  def test_by_many
    r = `cat test/access.log | ./apache-log-geo --city dublin | wc -l`.strip
    assert_equal "8", r
    r = `cat test/access.log | ./apache-log-geo --city qwe | wc -l`.strip
    assert_equal "0", r
    r = `cat test/access.log | ./apache-log-geo --postcode 20149 | wc -l`.strip
    assert_equal "1", r
    r = `cat test/access.log | ./apache-log-geo --sub virginia | wc -l`.strip
    assert_equal "3", r
  end
end

class SmokeLookup < Minitest::Test
  def test_json
    r = `printf "\n\n2.3.4.5 q\nq\n6.7.8.9" | ./mmdb-lookup`.split("\n").map{|v| JSON.parse v}
    assert_equal 'France', r[0]['country']
    assert_equal 1, r[1]['error']
    assert_equal 'US', r[2]['country_code']

    r = `./mmdb-lookup 2.3.4.5 q 6.7.8.9`.split("\n").map{|v| JSON.parse v}
    assert_equal 'France', r[0]['country']
    assert_equal 1, r[1]['error']
    assert_equal 'US', r[2]['country_code']
  end

  def test_shell
    r = `eval \`./mmdb-lookup 5.1.0.0 q e -f shell\`; echo $subdivisions`.strip
    assert_equal 'Kyiv City', r
  end
end
