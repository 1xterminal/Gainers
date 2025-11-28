import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/weight_model.dart';

class WeightRepository {
	final SupabaseClient _client;

	WeightRepository(this._client);

	Future<void> addWeightLog(WeightLog log) async {
		final userId = _client.auth.currentUser?.id;
		if (userId == null) throw Exception('Cannot get userId, user may not logged in');

		final data = log.toJson();
		data['user_id'] = userId;

		await _client.from('weight_logs').insert(data);
	}

	Future<void> updateWeightLog(WeightLog log) async {
		if (log.id == null) throw Exception('Log ID is required for update');
		await _client.from('weight_logs').update(log.toJson()).eq('id', log.id!);
	}

	Future<List<WeightLog>> getWeightLogs(DateTime date) async {
		final userId = _client.auth.currentUser?.id;
		if (userId == null) return [];

		final response = await _client
			.from('weight_logs')
			.select()
			.eq('user_id', userId)
			.order('created_at', ascending: true);

		return (response as List).map((e) => WeightLog.fromJson(e)).toList();
	}

	Future<void> deleteWeightLog(int id) async {
		await _client.from('weight_logs').delete().eq('id', id);
	}

}