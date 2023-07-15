require 'pagy_cursor/pagy/cursor'
class Pagy

  module Backend ; private         # the whole module is private so no problem with including it in a controller

    # Return Pagy object and items
    def pagy_cursor(collection, vars={}, options={})
      pagy = Pagy::Cursor.new(pagy_cursor_get_vars(collection, vars))

      items =  pagy_cursor_get_items(collection, pagy, pagy.position)
      items = items[0..pagy.items-1] if (pagy.has_more = pagy_cursor_has_more?(items, pagy))

      if items.present?
        pagy.prev = items[0].send(pagy.primary_key)
        pagy.next = items[-1].send(pagy.primary_key)
      end

      return pagy, items
    end

    def pagy_cursor_get_vars(collection, vars)
      vars[:arel_table] = collection.arel_table
      vars[:primary_key] = collection.primary_key
      vars[:backend] = 'sequence'
      vars
    end

    def pagy_cursor_get_items(collection, pagy, position=nil)
      if position.present?
        sql_comparation = pagy.arel_table[pagy.primary_key].send(pagy.comparation, position)
        collection = collection.where(sql_comparation)
      end
      collection.reorder(pagy.order).limit(pagy.items + 1)
    end

    def pagy_cursor_has_more?(collection, pagy)
      return false if collection.blank?

      collection.length > pagy.items
    end
  end
end
