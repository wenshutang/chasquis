require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get contactanos" do
    get :contactanos
    assert_response :success
  end

  test "should get preguntas_frequentes" do
    get :preguntas_frequentes
    assert_response :success
  end

  test "should get terminos_de_uso" do
    get :terminos_de_uso
    assert_response :success
  end

  test "should get quienes_somos" do
    get :quienes_somos
    assert_response :success
  end

end
