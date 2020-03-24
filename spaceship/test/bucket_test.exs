defmodule Spaceship.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Spaceship.Bucket.start_link([])
    %{bucket: bucket}
  end

  test 'fetching inexistent key returns nil', %{bucket: bucket} do
    assert Spaceship.Bucket.get(bucket, 'inexistent_key') == nil
  end

  test 'stores value by key', %{bucket: bucket} do
    Spaceship.Bucket.put(bucket, 'a_key', :a_value)
    assert Spaceship.Bucket.get(bucket, 'a_key') == :a_value
  end

  test 'deletes value by key', %{bucket: bucket} do
    Spaceship.Bucket.put(bucket, 'a_key', :a_value)
    Spaceship.Bucket.delete(bucket, 'a_key')
    assert Spaceship.Bucket.get(bucket, 'a_key') == nil
  end
end
