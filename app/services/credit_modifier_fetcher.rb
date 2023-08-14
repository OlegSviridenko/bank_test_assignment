class CreditModifierFetcher
  def initialize(personal_code)
    @personal_code = personal_code
  end

  # In a real application, you would fetch the credit modifier from an external source or database
  # based on the personal code.
  # For the sake of this example, we will use a mocked codes mapping.

  def call
    mocked_list.fetch(@personal_code, 0)
  end

  private

  def mocked_list
    {
      '49002010965' => 0,
      '49002010976' => 100,
      '49002010987' => 300,
      '49002010998' => 1000
    }
  end
end
